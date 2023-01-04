# frozen_string_literal: true

module Timescaledb
  module Rails
    module Model
      # :nodoc:
      module Scopes
        extend ActiveSupport::Concern

        # rubocop:disable Metrics/BlockLength
        included do
          scope :last_year, lambda {
            date = Date.current - 1.year

            between(date.beginning_of_year, date.end_of_year)
          }

          scope :last_month, lambda {
            date = Date.current - 1.month

            between(date.beginning_of_month, date.end_of_month)
          }

          scope :last_week, lambda {
            date = Date.current - 1.week

            between(date.beginning_of_week, date.end_of_week)
          }

          scope :yesterday, lambda {
            where("DATE(#{hypertable_time_column_name}) = ?", Date.current - 1.day)
          }

          scope :this_year, lambda {
            between(Date.current.beginning_of_year, Date.current.end_of_year)
          }

          scope :this_month, lambda {
            between(Date.current.beginning_of_month, Date.current.end_of_month)
          }

          scope :this_week, lambda {
            between(Date.current.beginning_of_week, Date.current.end_of_week)
          }

          scope :today, lambda {
            where("DATE(#{hypertable_time_column_name}) = ?", Date.current)
          }

          scope :after, lambda { |time|
            where("#{hypertable_time_column_name} > ?", time)
          }

          scope :at_time, lambda { |time|
            where(hypertable_time_column_name => time)
          }

          scope :between, lambda { |from, to|
            where(hypertable_time_column_name => from..to)
          }
        end
        # rubocop:enable Metrics/BlockLength
      end
    end
  end
end
