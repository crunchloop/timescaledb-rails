# TimescaleDB extension for Rails [![Gem Version](https://badge.fury.io/rb/timescaledb-rails.svg)](https://badge.fury.io/rb/timescaledb-rails) [![Actions Status](https://github.com/crunchloop/timescaledb-rails/workflows/CI/badge.svg?branch=main)](https://github.com/crunchloop/timescaledb-rails/actions?query=workflow%3ACI)

`timescaledb-rails` extends ActiveRecord PostgreSQL adapter and provides features from [`TimescaleDB`](https://www.timescale.com). It provides support for hypertables and other features added by TimescaleDB PostgreSQL extension.


## Installation

Install `timescaledb-rails` from RubyGems:

``` sh
$ gem install timescaledb-rails
```

Or include it in your project's `Gemfile` with Bundler:

``` ruby
gem 'timescaledb-rails', '~> 0.1'
```

## Examples

### Migrations

Create a hypertable from a PostgreSQL table by doing:

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

Create a hypertable without a PostgreSQL table by doing:

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

Enable hypertable compression by doing:

```ruby
class AddEventCompression < ActiveRecord::Migration[7.0]
  def change
    add_hypertable_compression :events, 20.days, segment_by: :name, order_by: 'occurred_at DESC'
  end
end
```

Disable hypertable compression by doing:

```ruby
class RemoveEventCompression < ActiveRecord::Migration[7.0]
  def change
    remove_hypertable_compression :events
  end
end
```

Add hypertable retention policy by doing:

```ruby
class AddEventRetentionPolicy < ActiveRecord::Migration[7.0]
  def change
    add_hypertable_retention_policy :events, 1.year
  end
end
```

Remove hypertable retention policy by doing:

```ruby
class RemoveEventRetentionPolicy < ActiveRecord::Migration[7.0]
  def change
    remove_hypertable_retention_policy :events
  end
end
```

Add hypertable reorder policy by doing:

```ruby
class AddEventReorderPolicy < ActiveRecord::Migration[7.0]
  def change
    add_hypertable_reorder_policy :events, :index_events_on_created_at_and_name
  end
end
```

Remove hypertable reorder policy by doing:

```ruby
class RemoveEventReorderPolicy < ActiveRecord::Migration[7.0]
  def change
    remove_hypertable_reorder_policy :events
  end
end
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
