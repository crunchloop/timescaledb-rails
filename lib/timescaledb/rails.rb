# frozen_string_literal: true

require_relative './rails/railtie'
require_relative './rails/model'

require_relative './rails/extensions/active_record/base'
require_relative './rails/extensions/active_record/command_recorder'
require_relative './rails/extensions/active_record/postgresql_database_tasks'
require_relative './rails/extensions/active_record/schema_dumper'
require_relative './rails/extensions/active_record/schema_statements'

module Timescaledb
  # :nodoc:
  module Rails
    # Adds TimescaleDB support to ActiveRecord.
    def self.load
      ::ActiveRecord::Migration::CommandRecorder.prepend(ActiveRecord::CommandRecorder)
      ::ActiveRecord::Tasks::PostgreSQLDatabaseTasks.prepend(ActiveRecord::PostgreSQLDatabaseTasks)
      ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend(ActiveRecord::SchemaStatements)
      ::ActiveRecord::ConnectionAdapters::PostgreSQL::SchemaDumper.prepend(ActiveRecord::SchemaDumper)
      ::ActiveRecord::Base.include(ActiveRecord::Base) # rubocop:disable Rails/ActiveSupportOnLoad
    end
  end
end
