# frozen_string_literal: true

class AddExtensions < ActiveRecord::Migration[Rails.version[0..2]]
  def up
    enable_extension 'pgcrypto'
  end

  def down
    disable_extension 'pgcrypto'
  end
end
