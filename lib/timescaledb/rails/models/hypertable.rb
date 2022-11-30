# frozen_string_literal: true

module Timescaledb
  module Rails
    # :nodoc:
    class Hypertable < ::ActiveRecord::Base
      self.table_name = 'timescaledb_information.hypertables'
      self.primary_key = 'hypertable_name'

      has_many :compression_settings, foreign_key: 'hypertable_name',
                                      class_name: 'Timescaledb::Rails::CompressionSetting'
      has_many :dimensions, foreign_key: 'hypertable_name', class_name: 'Timescaledb::Rails::Dimension'
      has_many :jobs, foreign_key: 'hypertable_name', class_name: 'Timescaledb::Rails::Job'

      # @return [String]
      def time_column_name
        time_dimension.column_name
      end

      # @return [String]
      def chunk_time_interval
        interval = time_dimension.time_interval

        interval.is_a?(String) ? interval : interval.inspect
      end

      # @return [ActiveRecord::Relation<CompressionSetting>]
      def compression_segment_settings
        compression_settings.segmentby_setting
      end

      # @return [ActiveRecord::Relation<CompressionSetting>]
      def compression_order_settings
        compression_settings.orderby_setting.where.not(attname: time_column_name)
      end

      # @return [String]
      def compression_policy_interval
        ActiveSupport::Duration.parse(compression_job.config['compress_after']).inspect
      rescue ActiveSupport::Duration::ISO8601Parser::ParsingError
        compression_job.config['compress_after']
      end

      # @return [Boolean]
      def compression?
        compression_job.present?
      end

      private

      # @return [Job]
      def compression_job
        @compression_job ||= jobs.policy_compression.first
      end

      # @return [Dimension]
      def time_dimension
        @time_dimension ||= dimensions.time.first
      end
    end
  end
end
