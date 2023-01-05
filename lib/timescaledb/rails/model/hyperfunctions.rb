# frozen_string_literal: true

require 'timescaledb/rails/model/aggregate_functions'

module Timescaledb
  module Rails
    module Model
      # :nodoc:
      module Hyperfunctions
        TIME_BUCKET_ALIAS = 'time_bucket'

        # @return [ActiveRecord::Relation<ActiveRecord::Base>]
        def time_bucket(interval, target_column = nil)
          target_column ||= hypertable_time_column_name

          select("time_bucket('#{format_interval_value(interval)}', #{target_column}) as #{TIME_BUCKET_ALIAS}")
            .group(TIME_BUCKET_ALIAS)
            .order(TIME_BUCKET_ALIAS)
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
