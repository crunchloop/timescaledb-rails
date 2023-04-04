# frozen_string_literal: true

module Timescaledb
  module Rails
    # :nodoc:
    class ApplicationRecord < Railtie.config.record_base.constantize
      self.abstract_class = true
    end
  end
end
