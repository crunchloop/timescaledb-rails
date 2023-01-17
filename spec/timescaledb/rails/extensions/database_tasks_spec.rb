# frozen_string_literal: true

require 'spec_helper'

describe ActiveRecord::Tasks::DatabaseTasks do # rubocop:disable RSpec/FilePath
  before do
    # Silence hypertables/chunks pg_dump/TimescaleDB warnings.
    #
    # https://github.com/timescale/timescaledb/issues/1581
    if Rails.version.to_i >= 7
      ActiveRecord.dump_schemas = :schema_search_path
    else
      ActiveRecord::Base.dump_schemas = :schema_search_path
    end
  end

  after { database_delete_structure_file! }

  describe '.dump_schema' do
    before { ENV['SCHEMA'] = database_structure_name }

    context 'when :sql format' do
      it 'does not include _timescaledb_internal tables' do
        described_class.dump_schema(database_configuration, :sql)

        expect(database_structure).not_to include('_timescaledb_internal.compressed_data')
      end

      it 'includes ts_insert_blocker drop statements' do
        described_class.dump_schema(database_configuration, :sql)

        expect(database_structure).to include('DROP TRIGGER IF EXISTS ts_insert_blocker ON tdb.events;')
      end

      it 'includes create_hypertable statements' do
        described_class.dump_schema(database_configuration, :sql)

        expect(database_structure).to include("SELECT create_hypertable('tdb.events', 'created_at', if_not_exists => 'TRUE', chunk_time_interval => INTERVAL '2 days');") # rubocop:disable Layout/LineLength
      end

      it 'includes compression ALTER TABLE statements' do
        described_class.dump_schema(database_configuration, :sql)

        expect(database_structure).to include("ALTER TABLE tdb.events SET (timescaledb.compress, timescaledb.compress_segmentby = 'event_type, name', timescaledb.compress_orderby = 'occurred_at ASC, recorded_at DESC');") # rubocop:disable Layout/LineLength
      end

      it 'includes add_compression_policy statements' do
        described_class.dump_schema(database_configuration, :sql)

        expect(database_structure).to include("SELECT add_compression_policy('tdb.events', INTERVAL '20 days');")
      end

      it 'includes add_reorder_policy statements' do
        described_class.dump_schema(database_configuration, :sql)

        expect(database_structure).to include("SELECT add_reorder_policy('tdb.events', 'index_events_on_created_at_and_name');") # rubocop:disable Layout/LineLength
      end

      it 'includes add_retention_policy statements' do
        described_class.dump_schema(database_configuration, :sql)

        expect(database_structure).to include("SELECT add_retention_policy('tdb.events', INTERVAL '1 year');")
      end

      it 'includes create_continuous_aggregate statements' do # rubocop:disable RSpec/ExampleLength
        interval = Rails.version.to_i >= 7 ? 'P1D' : '1 day'

        described_class.dump_schema(database_configuration, :sql)

        expect(database_structure).to include(
          <<~SQL
            CREATE MATERIALIZED VIEW public.temperature_events WITH (timescaledb.continuous) AS
              SELECT time_bucket('#{interval}'::interval, events.created_at) AS time_bucket,
                  avg(events.value) AS avg
                 FROM events
                WHERE ((events.event_type)::text = 'temperature'::text)
                GROUP BY (time_bucket('#{interval}'::interval, events.created_at))
                ORDER BY (time_bucket('#{interval}'::interval, events.created_at));
          SQL
        )
      end

      it 'includes add_continuous_aggregate_policy statements' do
        described_class.dump_schema(database_configuration, :sql)

        expect(database_structure).to include("SELECT add_continuous_aggregate_policy('public.temperature_events', start_offset => INTERVAL '10 days', end_offset => INTERVAL '1 day', schedule_interval => INTERVAL '1 hour');") # rubocop:disable Layout/LineLength
      end
    end

    context 'when :ruby format' do
      it 'includes create_hypertable statements' do
        described_class.dump_schema(database_configuration, :ruby)

        expect(database_structure).to include('create_hypertable "events", "created_at", chunk_time_interval: "2 days"')
      end

      it 'includes add_hypertable_compression statements' do
        described_class.dump_schema(database_configuration, :ruby)

        expect(database_structure).to include('add_hypertable_compression "events", "20 days", segment_by: "event_type, name", order_by: "occurred_at ASC, recorded_at DESC"') # rubocop:disable Layout/LineLength
      end

      it 'includes add_hypertable_reorder_policy statements' do
        described_class.dump_schema(database_configuration, :ruby)

        expect(database_structure).to include('add_hypertable_reorder_policy "events", "index_events_on_created_at_and_name"') # rubocop:disable Layout/LineLength
      end

      it 'includes add_hypertable_retention_policy statements' do
        described_class.dump_schema(database_configuration, :ruby)

        expect(database_structure).to include('add_hypertable_retention_policy "events", "1 year"')
      end

      it 'includes create_continuous_aggregate statements' do # rubocop:disable RSpec/ExampleLength
        interval = Rails.version.to_i >= 7 ? 'P1D' : '1 day'

        described_class.dump_schema(database_configuration, :ruby)

        expect(database_structure).to include(
          <<-QUERY
  create_continuous_aggregate "temperature_events", <<-SQL
    SELECT time_bucket('#{interval}'::interval, events.created_at) AS time_bucket,
      avg(events.value) AS avg
     FROM events
    WHERE ((events.event_type)::text = 'temperature'::text)
    GROUP BY (time_bucket('#{interval}'::interval, events.created_at))
    ORDER BY (time_bucket('#{interval}'::interval, events.created_at));
  SQL
          QUERY
        )
      end

      it 'includes add_continuous_aggregate_policy statements' do
        described_class.dump_schema(database_configuration, :ruby)

        expect(database_structure)
          .to include('add_continuous_aggregate_policy "temperature_events", "10 days", "1 day", "1 hour"')
      end
    end
  end
end
