# frozen_string_literal: true

class CreatePayloadHypertable < ActiveRecord::Migration[Rails.version[0..2]]
  def up
    execute 'CREATE SEQUENCE payload_id_seq'

    create_hypertable :payloads, :created_at, chunk_time_interval: '5 days' do |t|
      t.integer :id, null: false, default: -> { "nextval('payload_id_seq')" }

      t.string :data, null: false
      t.string :format, null: false
      t.string :ip, null: false

      t.timestamps
    end

    add_index :payloads, %i[id created_at]
  end

  def down
    drop_table :payloads

    execute 'DROP SEQUENCE payload_id_seq'
  end
end
