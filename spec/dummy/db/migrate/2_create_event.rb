# frozen_string_literal: true

class CreateEvent < ActiveRecord::Migration[Rails.version[0..2]]
  def up
    create_schema 'tdb'

    create_table 'tdb.events', id: false do |t|
      t.integer :value, null: false

      t.string :event_type, null: false
      t.string :name, null: false

      t.time :occurred_at, null: false
      t.time :recorded_at, null: false

      t.timestamps
    end

    add_index :events, %i[created_at name]
  end

  def down
    drop_table :events
    drop_schema 'tdb'
  end
end
