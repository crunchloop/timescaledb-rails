# frozen_string_literal: true

class CreatePayloadHypertable < ActiveRecord::Migration[Rails.version[0..2]]
  def change
    create_hypertable :payloads, :created_at, chunk_time_interval: '5 days' do |t|
      t.string :ip, null: false

      t.timestamps
    end
  end
end
