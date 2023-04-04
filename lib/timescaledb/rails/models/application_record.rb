# frozen_string_literal: true

module Timescaledb
  module Rails
    # :nodoc:
    class ApplicationRecord < ::ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
