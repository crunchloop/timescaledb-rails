# frozen_string_literal: true

require 'active_record/tasks/postgresql_database_tasks'
require 'timescaledb/rails/orderby_compression'

module Timescaledb
  module Rails
    module ActiveRecord
      # :nodoc:
      module PostgreSQLDatabaseTasks
        # @override
        def structure_dump(filename, extra_flags) # rubocop:disable Metrics/MethodLength
          extra_flags = Array(extra_flags)
          extra_flags << timescale_structure_dump_default_flags if timescale_enabled?

          super(filename, extra_flags)

          return unless timescale_enabled?

          File.open(filename, 'a') do |file|
            Timescaledb::Rails::Hypertable.all.each do |hypertable|
              drop_ts_insert_trigger_statment(hypertable, file)
              create_hypertable_statement(hypertable, file)
              add_hypertable_compression_statement(hypertable, file)
              add_hypertable_reorder_policy_statement(hypertable, file)
              add_hypertable_retention_policy_statement(hypertable, file)
            end
          end
        end

        def drop_ts_insert_trigger_statment(hypertable, file)
          file << "---\n"
          file << "--- Drop ts_insert_blocker previously created by pg_dump to avoid pg errors, create_hypertable will re-create it again.\n" # rubocop:disable Layout/LineLength
          file << "---\n\n"
          file << "DROP TRIGGER IF EXISTS ts_insert_blocker ON #{hypertable.hypertable_name};\n"
        end

        def create_hypertable_statement(hypertable, file)
          options = hypertable_options(hypertable)

          file << "SELECT create_hypertable('#{hypertable.hypertable_name}', '#{hypertable.time_column_name}', #{options});\n\n" # rubocop:disable Layout/LineLength
        end

        def add_hypertable_compression_statement(hypertable, file)
          return unless hypertable.compression?

          options = hypertable_compression_options(hypertable)

          file << "ALTER TABLE #{hypertable.hypertable_name} SET (#{options});\n\n"
          file << "SELECT add_compression_policy('#{hypertable.hypertable_name}', INTERVAL '#{hypertable.compression_policy_interval}');\n\n" # rubocop:disable Layout/LineLength
        end

        def add_hypertable_reorder_policy_statement(hypertable, file)
          return unless hypertable.reorder?

          file << "SELECT add_reorder_policy('#{hypertable.hypertable_name}', '#{hypertable.reorder_policy_index_name}');\n\n" # rubocop:disable Layout/LineLength
        end

        def add_hypertable_retention_policy_statement(hypertable, file)
          return unless hypertable.retention?

          file << "SELECT add_retention_policy('#{hypertable.hypertable_name}', INTERVAL '#{hypertable.retention_policy_interval}');\n\n" # rubocop:disable Layout/LineLength
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

        # Returns `pg_dump` flag to exclude `_timescaledb_internal` schema tables.
        #
        # @return [String]
        def timescale_structure_dump_default_flags
          '--exclude-schema=_timescaledb_internal'
        end

        # @return [Boolean]
        def timescale_enabled?
          Timescaledb::Rails::Hypertable.table_exists?
        end
      end
    end
  end
end
