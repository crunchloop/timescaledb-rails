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

        def hypertable_options(hypertable)
          sql_statements = ["if_not_exists => 'TRUE'"]
          sql_statements << "chunk_time_interval => INTERVAL '#{hypertable.chunk_time_interval}'"

          sql_statements.compact.join(', ')
        end

        def hypertable_compression_options(hypertable)
          segmentby_setting = hypertable.compression_settings.segmentby_setting.first
          orderby_setting = hypertable.compression_settings.orderby_setting.first

          sql_statements = ['timescaledb.compress']
          sql_statements << "timescaledb.compress_segmentby = '#{segmentby_setting.attname}'" if segmentby_setting

          if orderby_setting
            orderby = Timescaledb::Rails::OrderbyCompression.new(orderby_setting.attname,
                                                                 orderby_setting.orderby_asc).to_s

            sql_statements << "timescaledb.compress_orderby = '#{orderby}'"
          end

          sql_statements.join(', ')
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
