# frozen_string_literal: true

require 'rails'

require_relative 'extensions/active_record/database_tasks'
require_relative 'extensions/active_record/schema_dumper'
require_relative 'extensions/active_record/schema_statements'

module Timescaledb
  module Rails
    # :nodoc:
    class Railtie < ::Rails::Railtie
      initializer 'timescaledb-rails.require_timescale_models' do
        ActiveSupport.on_load(:active_record) do
          require 'timescaledb/rails/models'
        end
      end

      initializer 'timescaledb-rails.add_timescale_support_to_active_record' do
        ActiveSupport.on_load(:active_record) do
          ::ActiveRecord::Tasks::PostgreSQLDatabaseTasks.prepend(
            Timescaledb::Rails::ActiveRecord::DatabaseTasks
          )

          ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend(
            Timescaledb::Rails::ActiveRecord::SchemaStatements
          )

          ::ActiveRecord::ConnectionAdapters::PostgreSQL::SchemaDumper.prepend(
            Timescaledb::Rails::ActiveRecord::SchemaDumper
          )
        end
      end
    end
  end
end
