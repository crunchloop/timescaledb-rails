# frozen_string_literal: true

class CreatePayloadHypertable < ActiveRecord::Migration[Rails.version[0..2]]
  def change
    create_hypertable 'public.payloads', :created_at, chunk_time_interval: 5.days do |t|
      t.uuid :id, null: false, default: -> { 'gen_random_uuid()' }

      t.string :data, null: false
      t.string :format, null: false
      t.string :ip, null: false

      t.timestamps
    end

    add_index :payloads, %i[id created_at]
  end
end
