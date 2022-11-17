# frozen_string_literal: true

require 'active_record/connection_adapters/postgresql_adapter'

module Timescaledb
  module Rails
    module ActiveRecord
      # :nodoc:
      module SchemaDumper
        def table(table, stream)
          super(table, stream)

          return unless timescale_enabled?
          return if (hypertable = Timescaledb::Rails::Hypertable.find_by(hypertable_name: table)).nil?

          hypertable(hypertable, stream)
        end

        private

        def hypertable(hypertable, stream)
          options = hypertable_options(hypertable)

          stream.puts "  create_hypertable #{hypertable.hypertable_name.inspect}, #{hypertable.time_column_name.inspect}, #{options}" # rubocop:disable Layout/LineLength
          stream.puts
        end

        def hypertable_options(hypertable)
          options = {
            chunk_time_interval: hypertable.chunk_time_interval
          }

          result = options.each_with_object([]) do |(key, value), memo|
            memo << "#{key}: #{format_hypertable_option_value(value)}"
            memo
          end

          result.join(', ')
        end

        def format_hypertable_option_value(value)
          case value
          when String then value.inspect
          when ActiveSupport::Duration then value.inspect.inspect
          else
            value
          end
        end

        def timescale_enabled?
          Timescaledb::Rails::Hypertable.table_exists?
        end
      end
    end
  end
end
