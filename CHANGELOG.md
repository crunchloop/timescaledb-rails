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
