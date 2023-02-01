# frozen_string_literal: true

class AddEventCompressionPolicy < ActiveRecord::Migration[Rails.version[0..2]]
  def change
    add_hypertable_compression_policy :events, 20.days
  end
end
