# frozen_string_literal: true

class CreateEventType < ActiveRecord::Migration[Rails.version[0..2]]
  def change
    create_table :event_types do |t|
      t.integer :type, null: false

      t.timestamps
    end

    add_belongs_to :events, :event_type
  end
end
