# frozen_string_literal: true

require 'active_record/tasks/postgresql_database_tasks'
require 'timescaledb/rails/orderby_compression'

module Timescaledb
  module Rails
    module ActiveRecord
      # :nodoc:
      # rubocop:disable Layout/LineLength
      module PostgreSQLDatabaseTasks # rubocop:disable Metrics/ModuleLength
        # @override
        def structure_dump(filename, extra_flags)
          extra_flags = Array(extra_flags)
          extra_flags |= timescale_structure_dump_default_flags if timescale_enabled?

          super(filename, extra_flags)

          return unless timescale_enabled?

          hypertables(filename)
          continuous_aggregates(filename)
        end

        def hypertables(filename)
          File.open(filename, 'a') do |file|
            Timescaledb::Rails::Hypertable.all.each do |hypertable|
              drop_ts_insert_trigger_statment(hypertable, file)
              create_hypertable_statement(hypertable, file)
              enable_hypertable_compression_statement(hypertable, file)
              add_hypertable_compression_policy_statement(hypertable, file)
              add_hypertable_reorder_policy_statement(hypertable, file)
              add_hypertable_retention_policy_statement(hypertable, file)
            end
          end
        end

        def continuous_aggregates(filename)
          File.open(filename, 'a') do |file|
            Timescaledb::Rails::ContinuousAggregate.dependency_ordered.each do |continuous_aggregate|
              create_continuous_aggregate_statement(continuous_aggregate, file)
              add_continuous_aggregate_policy_statement(continuous_aggregate, file)
            end
          end
        end

        def drop_ts_insert_trigger_statment(hypertable, file)
          file << "---\n"
          file << "--- Drop ts_insert_blocker previously created by pg_dump to avoid pg errors, create_hypertable will re-create it again.\n"
          file << "---\n\n"
          file << "DROP TRIGGER IF EXISTS ts_insert_blocker ON #{hypertable.hypertable_schema}.#{hypertable.hypertable_name};\n"
        end

        def create_hypertable_statement(hypertable, file)
          options = hypertable_options(hypertable)

          file << "SELECT create_hypertable('#{hypertable.hypertable_schema}.#{hypertable.hypertable_name}', '#{hypertable.time_column_name}', #{options});\n\n"
        end

        def enable_hypertable_compression_statement(hypertable, file)
          return unless hypertable.compression?

          options = hypertable_compression_options(hypertable)

          file << "ALTER TABLE #{hypertable.hypertable_schema}.#{hypertable.hypertable_name} SET (#{options});\n\n"
        end

        def add_hypertable_compression_policy_statement(hypertable, file)
          return unless hypertable.compression_policy?

          file << "SELECT add_compression_policy('#{hypertable.hypertable_schema}.#{hypertable.hypertable_name}', INTERVAL '#{hypertable.compression_policy_interval}');\n\n"
        end

        def add_hypertable_reorder_policy_statement(hypertable, file)
          return unless hypertable.reorder?

          file << "SELECT add_reorder_policy('#{hypertable.hypertable_schema}.#{hypertable.hypertable_name}', '#{hypertable.reorder_policy_index_name}');\n\n"
        end

        def add_hypertable_retention_policy_statement(hypertable, file)
          return unless hypertable.retention?

          file << "SELECT add_retention_policy('#{hypertable.hypertable_schema}.#{hypertable.hypertable_name}', INTERVAL '#{hypertable.retention_policy_interval}');\n\n"
        end

        def create_continuous_aggregate_statement(continuous_aggregate, file)
          file << "CREATE MATERIALIZED VIEW #{continuous_aggregate.view_schema}.#{continuous_aggregate.view_name} WITH (timescaledb.continuous) AS\n"
          file << "#{continuous_aggregate.view_definition.strip.indent(2)}\n\n"
        end

        def add_continuous_aggregate_policy_statement(continuous_aggregate, file)
          return unless continuous_aggregate.refresh?

          start_offset = continuous_aggregate.refresh_start_offset
          end_offset = continuous_aggregate.refresh_end_offset
          schedule_interval = continuous_aggregate.refresh_schedule_interval

          file << "SELECT add_continuous_aggregate_policy('#{continuous_aggregate.view_schema}.#{continuous_aggregate.view_name}', start_offset => INTERVAL '#{start_offset}', end_offset => INTERVAL '#{end_offset}', schedule_interval => INTERVAL '#{schedule_interval}');\n\n"
        end

        def hypertable_options(hypertable)
          sql_statements = ["if_not_exists => 'TRUE'"]
          sql_statements << "chunk_time_interval => INTERVAL '#{hypertable.chunk_time_interval}'"

          sql_statements.compact.join(', ')
        end

        def hypertable_compression_options(hypertable)
          sql_statements = ['timescaledb.compress']

          if (segments = compression_segment_settings(hypertable)).present?
            sql_statements << "timescaledb.compress_segmentby = '#{segments.join(', ')}'"
          end

          if (orders = compression_order_settings(hypertable)).present?
            sql_statements << "timescaledb.compress_orderby = '#{orders.join(', ')}'"
          end

          sql_statements.join(', ')
        end

        def compression_order_settings(hypertable)
          hypertable.compression_order_settings.map do |os|
            Timescaledb::Rails::OrderbyCompression.new(os.attname, os.orderby_asc).to_s
          end
        end

        def compression_segment_settings(hypertable)
          hypertable.compression_segment_settings.map(&:attname)
        end

        # Returns `pg_dump` flags to exclude `_timescaledb_internal` schema tables and
        # exclude the corresponding continuous aggregate views.
        #
        # @return [Array<String>]
        def timescale_structure_dump_default_flags
          flags = ['--exclude-schema=_timescaledb_internal']

          Timescaledb::Rails::ContinuousAggregate.pluck(:view_schema, :view_name).each do |view_schema, view_name|
            flags << "--exclude-table=#{view_schema}.#{view_name}"
          end

          flags
        end

        # @return [Boolean]
        def timescale_enabled?
          pool_name(connection.pool) == pool_name(Timescaledb::Rails::Hypertable.connection.pool) &&
            Timescaledb::Rails::Hypertable.table_exists?
        end

        def pool_name(pool)
          if pool.respond_to?(:db_config)
            pool.db_config.name
          elsif pool.respond_to?(:spec)
            pool.spec.name
          else
            raise "Don't know how to get pool name from #{pool.inspect}"
          end
        end
      end
      # rubocop:enable Layout/LineLength
    end
  end
end
