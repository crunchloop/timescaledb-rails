##  0.1.6 (April 19, 2023) ##

*   Allow Timescale to be a non-primary Rails DB

    ```ruby
    Rails.application.configure do
      config.after_initialize do
        Timescaledb::Rails::ApplicationRecord.connects_to database: { writing: :timescale, reading: :timescale }
      end
    end
    ```

*   Decouple compression policy from the compression settings

    **Before**
    ```ruby
    add_hypertable_compression :events, 20.days, segment_by: 'event_type, name', order_by: 'occurred_at ASC, recorded_at DESC'
    ```

    **After**
    ```ruby
    enable_hypertable_compression :events, segment_by: 'event_type, name', order_by: 'occurred_at ASC, recorded_at DESC'
    add_hypertable_compression_policy :events, 20.days
    ```

##  0.1.5 (January 24, 2023) ##

*   Add continuous aggregates refresh support

    ```ruby
    aggregate = Event.hypertable.continuous_aggregates.first

    aggregate.refresh!(5.days.ago, 1.day.ago)
    ```

*   Add chunk reorder support

    ```ruby
    chunk = Event.hypertable.chunks.first

    # If an index is not specified, it will use the one from the reorder policy
    # In case there is no reorder policy index it will raise an ArgumentError
    chunk.reorder!

    # If an index is specified it will use that index
    chunk.reorder!(index)
    ```

*   Add continuous aggregates migration APIs

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

*   Add finder APIs to Active Record models

    ```ruby
    # When you know the exact time value
    Payload.find_at_time(111, Time.new(2022, 01, 01, 10, 15, 30))

    # If you know that the record occurred after a given time
    Payload.find_after(222, 11.days.ago)

    # Lastly, if you want to scope the search by a time range
    Payload.find_between(333, 1.week.ago, 1.day.ago)
    ```

*   Add time_bucket support to Active Record models

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

##  0.1.4 (December 30, 2022) ##

*   Add time scopes to Active Record models

    | scope         | description                     |
    | ------------- | ------------------------------- |
    | last_year     | Returns records from last year  |
    | last_month    | Returns records from last month |
    | last_week     | Returns records from last week  |
    | this_year     | Returns records from this year  |
    | this_month    | Returns records from this month |
    | this_week     | Returns records from this week  |
    | yesterday     | Returns records from yesterday  |
    | today         | Returns records from today      |

*   Add hypertable reorder policy support

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

*   Add chunk compression support

    ```ruby
    chunk = Event.hypertable_chunks.first

    chunk.compress! unless chunk.is_compressed?

    chunk.decompress! if chunk.is_compressed?
    ```

*   Add TimescaleDB support to Active Record models

    ```ruby
    class Event < ActiveRecord::Base
      include Timescaledb::Rails::Model
    end
    ```

*   Add hypertable retention policy support

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

*   Add support to compress by multiple columns

##  0.1.3 (November 29, 2022) ##

*   Define ActiveRecord::CommandRecorder methods for all timescaledb migration methods and also
    define their invert command methods.

*   Disable hypertable compression by doing:

    ```ruby
    class RemoveEventCompression < ActiveRecord::Migration[7.0]
      def change
        remove_hypertable_compression :events
      end
    end
    ```

*   Fix `structure_dump_flags` not working in Rails 6.

*   Add `bin/ci` to run tests using all supported rails versions + code linter.

##  0.1.2 (November 24, 2022) ##

*   Exclude `_timescaledb_internal` tables from structure.sql to avoid collision
    issues when enabling compression on hypertables.

##  0.1.1 (November 22, 2022) ##

*   Fix suggested version dependencies by rubygems.

##  0.1.0 (November 22, 2022) ##

*   Create a hypertable from a PostgreSQL table by doing:

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

*   Create a hypertable without a PostgreSQL table by doing:

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

*   Enable hypertable compression by doing:

    ```ruby
    class AddEventCompression < ActiveRecord::Migration[7.0]
      def change
        add_hypertable_compression :events, 20.days, segment_by: :name, order_by: 'occurred_at DESC'
      end
    end
    ```
