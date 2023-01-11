# frozen_string_literal: true

module Timescaledb
  module Rails
    module ActiveRecord
      # :nodoc:
      module SchemaStatements
        # Returns an array of hypertable names defined in the database.
        def hypertables
          query_values('SELECT hypertable_name FROM timescaledb_information.hypertables')
        end

        # Checks to see if the hypertable exists on the database.
        #
        #   hypertable_exists?(:developers)
        #
        def hypertable_exists?(hypertable)
          query_value(
            <<-SQL.squish
              SELECT COUNT(*) FROM timescaledb_information.hypertables WHERE hypertable_name = #{quote(hypertable)}
            SQL
          ).to_i.positive?
        end

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

        # Enables compression and sets compression options.
        #
        #   add_hypertable_compression('events', 7.days, segment_by: :created_at, order_by: :name)
        #
        def add_hypertable_compression(table_name, compress_after, segment_by: nil, order_by: nil)
          compress_after = compress_after.inspect if compress_after.is_a?(ActiveSupport::Duration)

          options = ['timescaledb.compress']
          options << "timescaledb.compress_orderby = '#{order_by}'" unless order_by.nil?
          options << "timescaledb.compress_segmentby = '#{segment_by}'" unless segment_by.nil?

          execute "ALTER TABLE #{table_name} SET (#{options.join(', ')})"

          execute "SELECT add_compression_policy('#{table_name}', INTERVAL '#{compress_after.inspect}')"
        end

        # Disables compression from given table.
        #
        #   remove_hypertable_compression('events')
        #
        def remove_hypertable_compression(table_name, compress_after = nil, segment_by: nil, order_by: nil) # rubocop:disable Lint/UnusedMethodArgument
          execute "SELECT remove_compression_policy('#{table_name.inspect}');"
        end

        # Add a data retention policy to given hypertable.
        #
        #   add_hypertable_retention_policy('events', 7.days)
        #
        def add_hypertable_retention_policy(table_name, drop_after)
          execute "SELECT add_retention_policy('#{table_name}', INTERVAL '#{drop_after.inspect}')"
        end

        # Removes data retention policy from given hypertable.
        #
        #   remove_hypertable_retention_policy('events')
        #
        def remove_hypertable_retention_policy(table_name, _drop_after = nil)
          execute "SELECT remove_retention_policy('#{table_name}')"
        end

        # Adds a policy to reorder chunks on a given hypertable index in the background.
        #
        #   add_hypertable_reorder_policy('events', 'index_events_on_created_at_and_name')
        #
        def add_hypertable_reorder_policy(table_name, index_name)
          execute "SELECT add_reorder_policy('#{table_name}', '#{index_name}')"
        end

        # Removes a policy to reorder a particular hypertable.
        #
        #   remove_hypertable_reorder_policy('events')
        #
        def remove_hypertable_reorder_policy(table_name, _index_name = nil)
          execute "SELECT remove_reorder_policy('#{table_name}')"
        end

        # Creates a continuous aggregate
        #
        #   create_continuous_aggregate(
        #     'temperature_events', 'SELECT * FROM events where event_type_id = 1'
        #   )
        #
        def create_continuous_aggregate(view_name, view_query)
          execute "CREATE MATERIALIZED VIEW #{view_name} WITH (timescaledb.continuous) AS #{view_query}"
        end

        # Drops a continuous aggregate
        #
        #   drop_continuous_aggregate('temperature_events')
        #
        def drop_continuous_aggregate(view_name, _view_query = nil)
          execute "DROP MATERIALIZED VIEW #{view_name};"
        end

        # @return [String]
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
