# frozen_string_literal: true

require 'timescaledb/rails/models/concerns/durationable'

module Timescaledb
  module Rails
    # :nodoc:
    class ContinuousAggregate < ::ActiveRecord::Base
      include Timescaledb::Rails::Models::Durationable

      self.table_name = 'timescaledb_information.continuous_aggregates'
      self.primary_key = 'materialization_hypertable_name'

      has_many :jobs, foreign_key: 'hypertable_name', class_name: 'Timescaledb::Rails::Job'

      # Manually refresh a continuous aggregate.
      #
      # @param [DateTime] start_time
      # @param [DateTime] end_time
      #
      def refresh!(start_time = 'NULL', end_time = 'NULL')
        ::ActiveRecord::Base.connection.execute(
          "CALL refresh_continuous_aggregate('#{view_name}', #{start_time}, #{end_time});"
        )
      end

      # @return [String]
      def refresh_start_offset
        parse_duration(refresh_job.config['start_offset'])
      end

      # @return [String]
      def refresh_end_offset
        parse_duration(refresh_job.config['end_offset'])
      end

      # @return [String]
      def refresh_schedule_interval
        interval = refresh_job.schedule_interval

        interval.is_a?(String) ? parse_duration(interval) : interval.inspect
      end

      # @return [Boolean]
      def refresh?
        refresh_job.present?
      end

      private

      # @return [Job]
      def refresh_job
        @refresh_job ||= jobs.policy_refresh_continuous_aggregate.first
      end
    end
  end
end
