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
        def create_hypertable(table_name, time_column_name, **options, &block)
          options = options.symbolize_keys
          options_as_sql = hypertable_options_to_sql(options)

          if block
            primary_key = options[:primary_key]
            force = options[:force]

            create_table(table_name, id: false, primary_key: primary_key, force: force, **options, &block)
          end

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
