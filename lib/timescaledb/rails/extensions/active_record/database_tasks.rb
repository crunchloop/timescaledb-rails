# frozen_string_literal: true

module Timescaledb
  module Rails
    module ActiveRecord
      # :nodoc:
      module DatabaseTasks
        # @override
        def structure_dump_flags_for(adapter)
          return (flags = super) if adapter != 'postgresql'

          if flags.nil?
            timescaledb_structure_dump_default_flags
          elsif flags.is_a?(Array)
            flags << timescaledb_structure_dump_default_flags
          elsif flags.is_a?(String)
            "#{flags} #{timescaledb_structure_dump_default_flags}"
          else
            flags
          end
        end

        # Returns `pg_dump` flag to exclude `_timescaledb_internal` schema tables.
        #
        # @return [String]
        def timescaledb_structure_dump_default_flags
          '--exclude-schema=_timescaledb_internal'
        end
      end
    end
  end
end
