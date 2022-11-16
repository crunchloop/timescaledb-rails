# TimescaleDB extension for Rails [![Actions Status](https://github.com/crunchloop/timescaledb-rails/workflows/CI/badge.svg?branch=main)](https://github.com/crunchloop/timescaledb-rails/actions?query=workflow%3ACI)

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

Create a hypertable from a PostgreSQL table by doing:

```ruby
class CreateEvent < ActiveRecord::Migration[7.0]
  def change
    create_table :events, id: false do |t|
      t.string :name, null: false

      t.timestamps
    end

    create_hypertable :events, :created_at, chunk_time_interval: '2 days'
  end
end
```

## Supported Ruby/Rails versions

Supported Ruby/Rails versions are listed in [`.github/workflows/ci.yaml`](https://github.com/crunchloop/timescaledb-rails/blob/main/.github/workflows/ci.yaml)

## License

Released under the MIT License.  See the [LICENSE][] file for further details.

[license]: LICENSE

## About Crunchloop

![crunchloop](https://crunchloop.io/logo-blue.png)

`timescaledb-rails` is supported with :heart: by [Crunchloop](https://crunchloop.io). We strongly believe in giving back :rocket:. Let's work together [`Get in touch`](https://crunchloop.io/contact).
