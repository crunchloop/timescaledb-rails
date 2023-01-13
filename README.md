# TimescaleDB extension for Rails [![Gem Version](https://badge.fury.io/rb/timescaledb-rails.svg)](https://badge.fury.io/rb/timescaledb-rails) [![Actions Status](https://github.com/crunchloop/timescaledb-rails/workflows/CI/badge.svg?branch=main)](https://github.com/crunchloop/timescaledb-rails/actions?query=workflow%3ACI)

`timescaledb-rails` extends ActiveRecord PostgreSQL adapter and provides features from [TimescaleDB](https://www.timescale.com). It provides support for hypertables and other features added by TimescaleDB PostgreSQL extension.

## Installation

Install `timescaledb-rails` from RubyGems:

``` sh
$ gem install timescaledb-rails
```

Or include it in your project's `Gemfile` with Bundler:

``` ruby
gem 'timescaledb-rails', '~> 0.1'
```

## Usage

### Migrations

Create a hypertable from a PostgreSQL table

```ruby
class CreateEvent < ActiveRecord::Migration[7.0]
  def change
    create_table :events, id: false do |t|
      t.string :name, null: false
      t.time :occurred_at, null: false

      t.timestamps
    end

    create_hypertable :events, :created_at, chunk_time_interval: '2 days'
  end
end
```

Create a hypertable without a PostgreSQL table

```ruby
class CreatePayloadHypertable < ActiveRecord::Migration[7.0]
  def change
    create_hypertable :payloads, :created_at, chunk_time_interval: '5 days' do |t|
      t.string :ip, null: false

      t.timestamps
    end
  end
end
```

Add hypertable compression

```ruby
class AddEventCompression < ActiveRecord::Migration[7.0]
  def up
    add_hypertable_compression :events, 20.days, segment_by: :name, order_by: 'occurred_at DESC'
  end

  def down
    remove_hypertable_compression :events
  end
end
```

Add hypertable retention policy

```ruby
class AddEventRetentionPolicy < ActiveRecord::Migration[7.0]
  def up
    add_hypertable_retention_policy :events, 1.year
  end

  def down
    remove_hypertable_retention_policy :events
  end
end
```

Add hypertable reorder policy

```ruby
class AddEventReorderPolicy < ActiveRecord::Migration[7.0]
  def up
    add_hypertable_reorder_policy :events, :index_events_on_created_at_and_name
  end

  def down
    remove_hypertable_reorder_policy :events
  end
end
```

Create continuous aggregate

```ruby
class CreateTemperatureEventAggregate < ActiveRecord::Migration[7.0]
  def up
    create_continuous_aggregate(
      :temperature_events,
      Event.time_bucket(1.day).avg(:value).temperature.to_sql
    )

    add_continuous_aggregate_policy(:temperature_events, 1.month, 1.day, 1.hour)
  end

  def down
    drop_continuous_aggregate(:temperature_events)

    remove_continuous_aggregate_policy(:temperature_events)
  end
end
```

> **Reversible Migrations:**
>
> Above examples implement `up`/`down` methods to better document all the different APIs. Feel free to use `change` method, timescaledb-rails defines all the reverse calls for each API method so Active Record can automatically figure out how to reverse your migration.

### Models

If one of your models need TimescaleDB support, just include `Timescaledb::Rails::Model`

```ruby
class Payload < ActiveRecord::Base
  include Timescaledb::Rails::Model

  self.primary_key = 'id'
end
```

When hypertable belongs to a non default schema, don't forget to override `table_name`

```ruby
class Event < ActiveRecord::Base
  include Timescaledb::Rails::Model

  self.table_name = 'v1.events'
end
```

Using `.find` is not recommended, to achieve more performat results, use these other find methods

```ruby
# When you know the exact time value
Payload.find_at_time(111, Time.new(2022, 01, 01, 10, 15, 30))

# If you know that the record occurred after a given time
Payload.find_after(222, 11.days.ago)

# Lastly, if you want to scope the search by a time range
Payload.find_between(333, 1.week.ago, 1.day.ago)
```

If you need to query data for a specific time period, `Timescaledb::Rails::Model` incluldes useful scopes

```ruby
# If you want to get all records from last year
Event.last_year #=> [#<Event name...>, ...]

# Or if you want to get records from this year
Event.this_year #=> [#<Event name...>, ...]

# Or even getting records from today
Event.today #=> [#<Event name...>, ...]
```

Here the list of all available scopes

* last_year
* last_month
* last_week
* this_year
* this_month
* this_week
* yesterday
* today

If you still need to query data by other time periods, take a look at these other scopes

```ruby
# If you want to get all records that occurred in the last 30 minutes
Event.after(30.minutes.ago) #=> [#<Event name...>, ...]

# If you want to get records that occurred in the last 4 days, excluding today
Event.between(4.days.ago, 1.day.ago) #=> [#<Event name...>, ...]

# If you want to get records that occurred at a specific time
Event.at_time(Time.new(2023, 01, 04, 10, 20, 30)) #=> [#<Event name...>, ...]
```

If you need information about your hypertable, use the following helper methods to get useful information

```ruby
# Hypertable metadata
Event.hypertable #=> #<Timescaledb::Rails::Hypertable ...>

# Hypertable chunks metadata
Event.hypertable_chunks #=> [#<Timescaledb::Rails::Chunk ...>, ...]

# Hypertable jobs, it includes jobs like compression, retention or reorder policies, etc.
Event.hypertable_jobs #=> [#<Timescaledb::Rails::Job ...>, ...]

# Hypertable dimensions, like time or space dimensions
Event.hypertable_dimensions #=> [#<Timescaledb::Rails::Dimension ...>, ...]

# Hypertable compression settings
Event.hypertable_compression_settings #=> [#<Timescaledb::Rails::CompressionSetting ...>, ...]
```

If you need to compress or decompress a specific chunk

```ruby
chunk = Event.hypertable_chunks.first

chunk.compress! unless chunk.is_compressed?

chunk.decompress! if chunk.is_compressed?
```

### Hyperfunctions

#### Time bucket

You can call the time bucket function with an interval (note that leaving the target column blank will use the default time column of the hypertable)

```ruby
Event.time_bucket(1.day)

Event.time_bucket('1 day')

Event.time_bucket(1.day, :created_at)

Event.time_bucket(1.day, 'occurred_at')
```

You may add aggregation like so:

```ruby
Event.time_bucket(1.day).avg(:column)
Event.time_bucket(1.day).sum(:column)
Event.time_bucket(1.day).min(:column)
Event.time_bucket(1.day).max(:column)
Event.time_bucket(1.day).count
```

## Contributing

Please read [CONTRIBUTING.md](./CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests.

## Supported Ruby/Rails versions

Supported Ruby/Rails versions are listed in [`.github/workflows/ci.yaml`](./.github/workflows/ci.yaml)

## License

Released under the MIT License.  See the [LICENSE][] file for further details.

[license]: LICENSE

## About Crunchloop

![crunchloop](https://crunchloop.io/logo-blue.png)

`timescaledb-rails` is supported with :heart: by [Crunchloop](https://crunchloop.io). We strongly believe in giving back :rocket:. Let's work together [`Get in touch`](https://crunchloop.io/contact).
