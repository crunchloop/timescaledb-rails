# frozen_string_literal: true

require 'active_record/connection_adapters/postgresql_adapter'
require 'timescaledb/rails/orderby_compression'
require 'tsort'

module Timescaledb
  module Rails
    module ActiveRecord
      # :nodoc:
      module SchemaDumper # rubocop:disable Metrics/ModuleLength
        # @override
        def tables(stream)
          super

          continuous_aggregates(stream)
          stream
        end

        def continuous_aggregates(stream)
          return unless timescale_enabled?

          Timescaledb::Rails::ContinuousAggregate.dependency_ordered.each do |ca|
            continuous_aggregate(ca, stream)
            continuous_aggregate_policy(ca, stream)
          end
        end

        def continuous_aggregate(continuous_aggregate, stream)
          stream.puts "  create_continuous_aggregate #{continuous_aggregate.view_name.inspect}, <<-SQL"
          stream.puts "  #{continuous_aggregate.view_definition.strip.indent(2)}"
          stream.puts '  SQL'
          stream.puts
        end

        def continuous_aggregate_policy(continuous_aggregate, stream)
          return unless continuous_aggregate.refresh?

          options = [
            continuous_aggregate.view_name.inspect,
            continuous_aggregate.refresh_start_offset.inspect,
            continuous_aggregate.refresh_end_offset.inspect,
            continuous_aggregate.refresh_schedule_interval.inspect
          ]

          stream.puts "  add_continuous_aggregate_policy #{options.join(', ')}"
          stream.puts
        end

        # @override
        def table(table, stream)
          super(table, stream)

          return unless timescale_enabled?
          return if (hypertable = Timescaledb::Rails::Hypertable.find_by(hypertable_name: table)).nil?

          hypertable(hypertable, stream)
          hypertable_compression(hypertable, stream)
          hypertable_compression_policy(hypertable, stream)
          hypertable_reorder_policy(hypertable, stream)
          hypertable_retention_policy(hypertable, stream)
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

          options = [hypertable.hypertable_name.inspect, hypertable_compression_options(hypertable)]

          stream.puts "  enable_hypertable_compression #{options.join(', ')}"
          stream.puts
        end

        def hypertable_compression_policy(hypertable, stream)
          return unless hypertable.compression_policy?

          options = [hypertable.hypertable_name.inspect, hypertable.compression_policy_interval.inspect]

          stream.puts "  add_hypertable_compression_policy #{options.join(', ')}"
          stream.puts
        end

        def hypertable_reorder_policy(hypertable, stream)
          return unless hypertable.reorder?

          options = [hypertable.hypertable_name.inspect, hypertable.reorder_policy_index_name.inspect]

          stream.puts "  add_hypertable_reorder_policy #{options.join(', ')}"
          stream.puts
        end

        def hypertable_retention_policy(hypertable, stream)
          return unless hypertable.retention?

          options = [hypertable.hypertable_name.inspect, hypertable.retention_policy_interval.inspect]

          stream.puts "  add_hypertable_retention_policy #{options.join(', ')}"
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
          [].tap do |result|
            if (segments = compression_segment_settings(hypertable)).present?
              result << "segment_by: #{segments.join(', ').inspect}"
            end

            if (orders = compression_order_settings(hypertable)).present?
              result << "order_by: #{orders.join(', ').inspect}"
            end
          end
        end

        def compression_order_settings(hypertable)
          hypertable.compression_order_settings.map do |os|
            Timescaledb::Rails::OrderbyCompression.new(os.attname, os.orderby_asc).to_s
          end
        end

        def compression_segment_settings(hypertable)
          hypertable.compression_segment_settings.map(&:attname)
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
          ApplicationRecord.timescale_connection?(@connection)
        end
      end
    end
  end
end
