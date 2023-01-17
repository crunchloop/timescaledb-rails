# frozen_string_literal: true

class AddEventReorderPolicy < ActiveRecord::Migration[Rails.version[0..2]]
  def change
    add_hypertable_reorder_policy :events, :index_events_on_created_at_and_name
  end
end
