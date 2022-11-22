# frozen_string_literal: true

module Timescaledb
  module Rails
    # :nodoc:
    class OrderbyCompression
      # @param [String] column_name.
      # @param [Boolean] orderby_asc.
      def initialize(column_name, orderby_asc)
        @column_name = column_name
        @orderby_asc = orderby_asc
      end

      # @return [String]
      def to_s
        [@column_name, (@orderby_asc ? 'ASC' : 'DESC')].join(' ')
      end
    end
  end
end
