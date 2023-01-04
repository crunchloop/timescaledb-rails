# frozen_string_literal: true

class Payload < ApplicationRecord
  include Timescaledb::Rails::Model

  self.primary_key = :id
end
