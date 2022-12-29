# frozen_string_literal: true

module Timescaledb
  module Rails
    # :nodoc:
    class Job < ::ActiveRecord::Base
      self.table_name = 'timescaledb_information.jobs'
      self.primary_key = 'hypertable_name'

      POLICY_COMPRESSION = 'policy_compression'
      POLICY_REORDER = 'policy_reorder'
      POLICY_RETENTION = 'policy_retention'

      scope :policy_compression, -> { where(proc_name: POLICY_COMPRESSION) }
      scope :policy_reorder, -> { where(proc_name: POLICY_REORDER) }
      scope :policy_retention, -> { where(proc_name: POLICY_RETENTION) }
    end
  end
end
