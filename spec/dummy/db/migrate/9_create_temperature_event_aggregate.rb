# frozen_string_literal: true

class CreateTemperatureEventAggregate < ActiveRecord::Migration[Rails.version[0..2]]
  disable_ddl_transaction!

  def change
    create_continuous_aggregate(
      'public.temperature_events',
      Event.time_bucket(1.day).avg(:value).temperature.to_sql
    )

    add_continuous_aggregate_policy('public.temperature_events', 10.days, 1.day, 1.hour)
  end
end
