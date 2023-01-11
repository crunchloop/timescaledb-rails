# frozen_string_literal: true

class CreateTemperatureEventAggregate < ActiveRecord::Migration[Rails.version[0..2]]
  disable_ddl_transaction!

  def change
    create_continuous_aggregate(
      :temperature_events,
      Event.time_bucket(1.day).avg(:value).temperature.to_sql
    )
  end
end
