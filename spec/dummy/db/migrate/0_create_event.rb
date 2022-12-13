# frozen_string_literal: true

class CreateEvent < ActiveRecord::Migration[Rails.version[0..2]]
  def change
    execute 'create schema v1'

    create_table 'v1.events', id: false do |t|
      t.string :name, null: false

      t.time :occured_at, null: false
      t.time :recorded_at, null: false

      t.timestamps
    end
  end
end
