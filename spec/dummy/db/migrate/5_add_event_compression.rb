# frozen_string_literal: true

class AddEventCompression < ActiveRecord::Migration[Rails.version[0..2]]
  def change
    enable_hypertable_compression :events, segment_by: 'event_type, name', order_by: 'occurred_at ASC, recorded_at DESC'
  end
end
