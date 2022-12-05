# frozen_string_literal: true

module Timescaledb
  module Rails
    module ActiveRecord
      # :nodoc:
      module CommandRecorder
        def create_hypertable(*args, &block)
          record(:create_hypertable, args, &block)
        end

        def add_hypertable_compression(*args, &block)
          record(:add_hypertable_compression, args, &block)
        end

        def remove_hypertable_compression(*args, &block)
          record(:remove_hypertable_compression, args, &block)
        end

        def add_hypertable_retention_policy(*args, &block)
          record(:add_hypertable_retention_policy, args, &block)
        end

        def remove_hypertable_retention_policy(*args, &block)
          record(:remove_hypertable_retention_policy, args, &block)
        end

        def invert_create_hypertable(args, &block)
          if block.nil?
            raise ::ActiveRecord::IrreversibleMigration, 'create_hypertable is only reversible if given a block (can be empty).' # rubocop:disable Layout/LineLength
          end

          [:drop_table, args.first, block]
        end

        def invert_add_hypertable_compression(args, &block)
          [:remove_hypertable_compression, args, block]
        end

        def invert_remove_hypertable_compression(args, &block)
          if args.size < 2
            raise ::ActiveRecord::IrreversibleMigration, 'remove_hypertable_compression is only reversible if given table name and compress period.' # rubocop:disable Layout/LineLength
          end

          [:add_hypertable_compression, args, block]
        end

        def invert_add_hypertable_retention_policy(args, &block)
          [:remove_hypertable_retention_policy, args, block]
        end

        def invert_remove_hypertable_retention_policy(args, &block)
          if args.size < 2
            raise ::ActiveRecord::IrreversibleMigration, 'remove_hypertable_retention_policy is only reversible if given table name and drop after period.' # rubocop:disable Layout/LineLength
          end

          [:add_hypertable_retention_policy, args, block]
        end
      end
    end
  end
end
