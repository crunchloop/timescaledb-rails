# frozen_string_literal: true

require 'active_record/tasks/postgresql_database_tasks'

module Timescaledb
  module Rails
    module ActiveRecord
      # :nodoc:
      module DatabaseTasks
        def structure_dump(filename, extra_flags)
          super

          return unless timescale_enabled?

          File.open(filename, 'a') do |file|
            Timescaledb::Rails::Hypertable.all.each do |hypertable|
              drop_ts_insert_trigger_statment(hypertable, file)
              create_hypertable_statement(hypertable, file)
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

        def hypertable_options(hypertable)
          sql_statements = ["if_not_exists => 'TRUE'"]
          sql_statements << "chunk_time_interval => INTERVAL '#{hypertable.chunk_time_interval.inspect}'"

          sql_statements.compact.join(', ')
        end

        def timescale_enabled?
          Timescaledb::Rails::Hypertable.table_exists?
        end
      end
    end
  end
end
