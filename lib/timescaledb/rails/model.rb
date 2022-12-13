# frozen_string_literal: true

module Timescaledb
  module Rails
    # :nodoc:
    module Model
      PUBLIC_SCHEMA_NAME = 'public'

      extend ActiveSupport::Concern

      # :nodoc:
      module ClassMethods
        # Returns only the name of the hypertable, table_name could include
        # the schema path, we need to remove it.
        #
        # @return [String]
        def hypertable_name
          table_name.split('.').last
        end

        # Returns the schema where hypertable is stored.
        #
        # @return [String]
        def hypertable_schema
          if table_name.split('.').size > 1
            table_name.split('.')[0..-2].join('.')
          else
            PUBLIC_SCHEMA_NAME
          end
        end

        # @return [Timescaledb::Rails::Hypertable]
        def hypertable
          Timescaledb::Rails::Hypertable.find_by(hypertable_where_options)
        end

        # @return [ActiveRecord::Relation<Timescaledb::Rails::Job>]
        def hypertable_jobs
          Timescaledb::Rails::Job.where(hypertable_where_options)
        end

        # @return [ActiveRecord::Relation<Timescaledb::Rails::Dimension>]
        def hypertable_dimensions
          Timescaledb::Rails::Dimension.where(hypertable_where_options)
        end

        # @return [ActiveRecord::Relation<Timescaledb::Rails::CompressionSetting>]
        def hypertable_compression_settings
          Timescaledb::Rails::CompressionSetting.where(hypertable_where_options)
        end

        private

        # Returns hypertable name and schema.
        #
        # @return [Hash]
        def hypertable_where_options
          { hypertable_name: hypertable_name, hypertable_schema: hypertable_schema }
        end
      end
    end
  end
end
