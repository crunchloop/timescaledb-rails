# frozen_string_literal: true

module Timescaledb
  module Rails
    # :nodoc:
    class Job < ::ActiveRecord::Base
      self.table_name = 'timescaledb_information.jobs'
      self.primary_key = 'hypertable_name'

      POLICY_COMPRESSION = 'policy_compression'

      scope :policy_compression, -> { where(proc_name: POLICY_COMPRESSION) }
    end
  end
end
