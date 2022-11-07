# frozen_string_literal: true

module Timescaledb
  module Rails
    # :nodoc:
    class Hypertable < ::ActiveRecord::Base
      self.table_name = 'timescaledb_information.hypertables'
      self.primary_key = 'hypertable_name'

      has_many :dimensions, foreign_key: 'hypertable_name', class_name: 'Timescaledb::Rails::Dimension'

      def time_column_name
        time_dimension.column_name
      end

      def chunk_time_interval
        time_dimension.time_interval
      end

      private

      def time_dimension
        @time_dimension ||= dimensions.time.first
      end
    end
  end
end
