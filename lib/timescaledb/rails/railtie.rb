# frozen_string_literal: true

require 'rails'

module Timescaledb
  module Rails
    # :nodoc:
    class Railtie < ::Rails::Railtie
      config.record_base = '::ActiveRecord::Base'

      config.to_prepare do
        ActiveSupport.on_load(:active_record) do
          require 'timescaledb/rails/models'
        end
      end

      config.to_prepare do
        ActiveSupport.on_load(:active_record) do
          Timescaledb::Rails.load
        end
      end
    end
  end
end
