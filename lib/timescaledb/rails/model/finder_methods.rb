# frozen_string_literal: true

module Timescaledb
  module Rails
    module Model
      # :nodoc:
      module FinderMethods
        # Adds a warning message to avoid calling find without filtering by time.
        #
        # @override
        def find(*args)
          warn "WARNING: Calling `.find` without filtering by `#{hypertable_time_column_name}` could cause performance issues, use built-in find_(at_time|between|after) methods for more performant results." # rubocop:disable Layout/LineLength

          super
        end

        # Finds records by primary key and chunk time.
        #
        # @param [Array<Integer>, Integer] id The primary key values.
        # @param [Time, Date, Integer] time The chunk time value.
        def find_at_time(id, time)
          at_time(time).find(id)
        end

        # Finds records by primary key and chunk time occurring between given time range.
        #
        # @param [Array<Integer>, Integer] id The primary key values.
        # @param [Time, Date, Integer] from The chunk from time value.
        # @param [Time, Date, Integer] to The chunk to time value.
        def find_between(id, from, to)
          between(from, to).find(id)
        end

        # Finds records by primary key and chunk time occurring after given time.
        #
        # @param [Array<Integer>, Integer] id The primary key values.
        # @param [Time, Date, Integer] from The chunk from time value.
        def find_after(id, from)
          after(from).find(id)
        end

        # Finds the first records for a hypertable according to the value of one column as ordered by another.
        #
        # @param [String] target_column The column to find the first value for.
        # @param [String] date_column The column to order by.
        def first_for_hypertable(target_column, date_column = nil)
          raise(no_hypertable_found_message) unless hypertable

          date_column ||= hypertable.time_column_name

          select("first(#{target_column}, #{date_column}) as first")
        end

        # Finds the last records for a hypertable according to the value of one column as ordered by another.
        #
        # @param [String] target_column The column to find the last value for.
        # @param [String] date_column The column to order by.
        def last_for_hypertable(target_column, date_column = nil)
          raise(no_hypertable_found_message) unless hypertable

          date_column ||= hypertable.time_column_name

          select("last(#{target_column}, #{date_column}) as last")
        end

        private

        def no_hypertable_found_message
          "No hypertable found for #{self}"
        end
      end
    end
  end
end
