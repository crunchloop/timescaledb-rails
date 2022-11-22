# frozen_string_literal: true

require 'active_record/connection_adapters/postgresql_adapter'
require 'timescaledb/rails/orderby_compression'

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
          hypertable_compression(hypertable, stream)
        end

        private

        def hypertable(hypertable, stream)
          options = [hypertable.hypertable_name.inspect, hypertable.time_column_name.inspect]
          options |= hypertable_options(hypertable)

          stream.puts "  create_hypertable #{options.join(', ')}"
          stream.puts
        end

        def hypertable_compression(hypertable, stream)
          return unless hypertable.compression?

          options = [hypertable.hypertable_name.inspect, hypertable.compression_policy_interval.inspect]
          options |= hypertable_compression_options(hypertable)

          stream.puts "  add_hypertable_compression #{options.join(', ')}"
          stream.puts
        end

        def hypertable_options(hypertable)
          options = {
            chunk_time_interval: hypertable.chunk_time_interval
          }

          options.each_with_object([]) do |(key, value), memo|
            memo << "#{key}: #{format_hypertable_option_value(value)}"
            memo
          end
        end

        def hypertable_compression_options(hypertable)
          segmentby_setting = hypertable.compression_settings.segmentby_setting.first
          orderby_setting = hypertable.compression_settings.orderby_setting.first

          [].tap do |result|
            result << "segment_by: #{segmentby_setting.attname.inspect}" if segmentby_setting

            if orderby_setting
              orderby = Timescaledb::Rails::OrderbyCompression.new(orderby_setting.attname,
                                                                   orderby_setting.orderby_asc).to_s

              result << "order_by: #{orderby.inspect}"
            end
          end
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
