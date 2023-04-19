# frozen_string_literal: true

require 'timescaledb/rails/model/aggregate_functions'

module Timescaledb
  module Rails
    module Model
      # :nodoc:
      module Hyperfunctions
        TIME_BUCKET_ALIAS = 'time_bucket'

        # @return [ActiveRecord::Relation<ActiveRecord::Base>]
        def time_bucket(interval, target_column = nil, select_alias: TIME_BUCKET_ALIAS)
          target_column &&= Arel.sql(target_column.to_s)
          target_column ||= arel_table[hypertable_time_column_name]

          time_bucket = Arel::Nodes::NamedFunction.new(
            'time_bucket',
            [Arel::Nodes.build_quoted(format_interval_value(interval)), target_column]
          )

          select(time_bucket.dup.as(select_alias))
            .group(time_bucket)
            .order(time_bucket)
            .extending(AggregateFunctions)
        end

        private

        def format_interval_value(value)
          value.is_a?(ActiveSupport::Duration) ? value.inspect : value
        end
      end
    end
  end
end
