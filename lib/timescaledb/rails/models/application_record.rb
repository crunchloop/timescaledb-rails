# frozen_string_literal: true

module Timescaledb
  module Rails
    # :nodoc:
    class ApplicationRecord < ::ActiveRecord::Base
      self.abstract_class = true

      def self.timescale_connection?(connection)
        pool_name = lambda do |pool|
          if pool.respond_to?(:db_config)
            pool.db_config.name
          elsif pool.respond_to?(:spec)
            pool.spec.name
          else
            raise "Don't know how to get pool name from #{pool.inspect}"
          end
        end

        pool_name[connection.pool] == pool_name[self.connection.pool]
      end
    end
  end
end
