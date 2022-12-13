# frozen_string_literal: true

module Timescaledb
  module Rails
    module ActiveRecord
      # :nodoc:
      module Base
        extend ActiveSupport::Concern

        # :nodoc:
        module ClassMethods
          # Returns if the current active record model is a hypertable.
          def hypertable?
            connection.hypertable_exists?(table_name)
          end
        end
      end
    end
  end
end
