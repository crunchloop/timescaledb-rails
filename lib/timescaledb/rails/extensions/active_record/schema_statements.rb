# frozen_string_literal: true

require 'active_record/connection_adapters/postgresql_adapter'

module Timescaledb
  module Rails
    module ActiveRecord
      # :nodoc:
      module SchemaStatements
        # Converts given standard PG table into a hypertable.
        #
        #   create_hypertable('readings', 'created_at', chunk_time_interval: '7 days')
        #
        def create_hypertable(table_name, time_column_name = 'created_at', **options)
          options_as_sql = hypertable_options_to_sql(options.symbolize_keys)

          execute "SELECT create_hypertable('#{table_name}', '#{time_column_name}', #{options_as_sql})"
        end

        def hypertable_options_to_sql(options)
          sql_statements = options.map do |option, value|
            case option
            when :chunk_time_interval then "chunk_time_interval => INTERVAL '#{value}'"
            when :if_not_exists then  "if_not_exists => #{value ? 'TRUE' : 'FALSE'}"
            end
          end

          sql_statements.compact.join(', ')
        end
      end
    end
  end
end
