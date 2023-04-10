# frozen_string_literal: true

require 'rails'

module Timescaledb
  module Rails
    # :nodoc:
    class Railtie < ::Rails::Railtie
      initializer 'timescaledb-rails.require_timescale_models' do
        ActiveSupport.on_load(:active_record) do
          require 'timescaledb/rails/models'
        end
      end

      initializer 'timescaledb-rails.add_timescale_support_to_active_record' do
        ActiveSupport.on_load(:active_record) do
          Timescaledb::Rails.load
        end
      end
    end
  end
end
