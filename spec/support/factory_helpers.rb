# frozen_string_literal: true

module Timescaledb
  module Rails
    module FactoryHelpers
      def create_payload(data:, created_at:, format: 'JSON', ip: '127.0.0.1')
        Payload.create!(data: data, format: format, ip: ip, created_at: created_at)
      end
    end
  end
end
