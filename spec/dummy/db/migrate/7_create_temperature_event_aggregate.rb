# frozen_string_literal: true

class CreateTemperatureEventAggregate < ActiveRecord::Migration[Rails.version[0..2]]
  disable_ddl_transaction!

  def change
    create_continuous_aggregate(
      :temperature_events,
      Event.time_bucket(1.day).avg(:value).temperature.to_sql
    )

    add_continuous_aggregate_policy(:temperature_events, 1.month, 1.day, 1.hour)
  end
end
