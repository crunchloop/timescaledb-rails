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
          t.time :occured_at, null: false

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
        add_hypertable_compression :events, 20.days, segment_by: :name, order_by: 'occured_at DESC'
      end
    end
    ```
