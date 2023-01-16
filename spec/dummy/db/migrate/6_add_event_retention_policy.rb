# frozen_string_literal: true

class AddEventRetentionPolicy < ActiveRecord::Migration[Rails.version[0..2]]
  def change
    add_hypertable_retention_policy :events, 1.year
  end
end
