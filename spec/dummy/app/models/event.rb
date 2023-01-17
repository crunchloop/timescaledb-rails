# frozen_string_literal: true

class Event < ApplicationRecord
  include Timescaledb::Rails::Model

  self.table_name = 'tdb.events'

  enum event_type: {
    temperature: 'temperature'
  }
end
