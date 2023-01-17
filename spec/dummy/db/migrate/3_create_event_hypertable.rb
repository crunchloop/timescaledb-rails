# frozen_string_literal: true

class CreateEventHypertable < ActiveRecord::Migration[Rails.version[0..2]]
  def up
    create_hypertable :events, :created_at, chunk_time_interval: 2.days
  end
end
