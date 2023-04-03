# frozen_string_literal: true

module Timescaledb
  module Rails
    # :nodoc:
    class Dimension < Railtie.config.record_base.constantize
      TIME_TYPE = 'Time'

      self.table_name = 'timescaledb_information.dimensions'

      attribute :time_interval, :interval if ::Rails.version.to_i >= 7

      scope :time, -> { where(dimension_type: TIME_TYPE) }
    end
  end
end
