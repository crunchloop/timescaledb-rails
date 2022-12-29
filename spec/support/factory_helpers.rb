# frozen_string_literal: true

module Timescaledb
  module Rails
    module FactoryHelpers
      def create_event(name:, created_at:, occurred_at: nil, recorded_at: nil)
        occurred_at ||= created_at
        recorded_at ||= created_at

        Event.create(
          name: name,
          occurred_at: occurred_at,
          recorded_at: recorded_at,
          created_at: created_at
        )
      end
    end
  end
end
