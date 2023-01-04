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

### Models

If one of your models need TimescaleDB support, just include `Timescaledb::Rails::Model`
```ruby
class Event < ActiveRecord::Base
  include Timescaledb::Rails::Model
end
```

If the hypertable does not belong to the default schema, don't forget to override `table_name`

```ruby
class Event < ActiveRecord::Base
  include Timescaledb::Rails::Model

  self.table_name = 'v1.events'
end
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
Event.time_bucket(1.day).select('avg(target) as target_avg')
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
