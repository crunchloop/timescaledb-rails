# frozen_string_literal: true

class Event < ApplicationRecord
  include Timescaledb::Rails::Model

  self.table_name = 'v1.events'
end
