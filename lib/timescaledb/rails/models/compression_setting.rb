# frozen_string_literal: true

module Timescaledb
  module Rails
    # :nodoc:
    class CompressionSetting < ::ActiveRecord::Base
      self.table_name = 'timescaledb_information.compression_settings'
      self.primary_key = 'hypertable_name'

      scope :segmentby_setting, -> { where.not(segmentby_column_index: nil).order(:segmentby_column_index) }
      scope :orderby_setting, -> { where.not(orderby_column_index: nil).order(:orderby_column_index) }
    end
  end
end
