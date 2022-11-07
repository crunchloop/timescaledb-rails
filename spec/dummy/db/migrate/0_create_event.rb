# frozen_string_literal: true

class CreateEvent < ActiveRecord::Migration[Rails.version[0..2]]
  def change
    create_table :events, id: false do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
