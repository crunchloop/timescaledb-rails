# frozen_string_literal: true

module Timescaledb
  module Rails
    module ActiveRecord
      # :nodoc:
      module CommandRecorder
        def create_hypertable(*args, &block)
          record(:create_hypertable, args, &block)
        end

        def enable_hypertable_compression(*args, &block)
          record(:enable_hypertable_compression, args, &block)
        end

        def disable_hypertable_compression(*args, &block)
          record(:disable_hypertable_compression, args, &block)
        end

        def add_hypertable_compression_policy(*args, &block)
          record(:add_hypertable_compression_policy, args, &block)
        end

        def remove_hypertable_compression_policy(*args, &block)
          record(:remove_hypertable_compression_policy, args, &block)
        end

        def add_hypertable_reorder_policy(*args, &block)
          record(:add_hypertable_reorder_policy, args, &block)
        end

        def remove_hypertable_reorder_policy(*args, &block)
          record(:remove_hypertable_reorder_policy, args, &block)
        end

        def add_hypertable_retention_policy(*args, &block)
          record(:add_hypertable_retention_policy, args, &block)
        end

        def remove_hypertable_retention_policy(*args, &block)
          record(:remove_hypertable_retention_policy, args, &block)
        end

        def create_continuous_aggregate(*args, &block)
          record(:create_continuous_aggregate, args, &block)
        end

        def drop_continuous_aggregate(*args, &block)
          record(:drop_continuous_aggregate, args, &block)
        end

        def add_continuous_aggregate_policy(*args, &block)
          record(:add_continuous_aggregate_policy, args, &block)
        end

        def remove_continuous_aggregate_policy(*args, &block)
          record(:remove_continuous_aggregate_policy, args, &block)
        end

        def invert_create_hypertable(args, &block)
          if block.nil?
            raise ::ActiveRecord::IrreversibleMigration, 'create_hypertable is only reversible if given a block (can be empty).' # rubocop:disable Layout/LineLength
          end

          [:drop_table, args.first, block]
        end

        def invert_enable_hypertable_compression(args, &block)
          [:disable_hypertable_compression, args, block]
        end

        def invert_disable_hypertable_compression(args, &block)
          [:enable_hypertable_compression, args, block]
        end

        def invert_add_hypertable_compression_policy(args, &block)
          [:remove_hypertable_compression_policy, args, block]
        end

        def invert_remove_hypertable_compression_policy(args, &block)
          if args.size < 2
            raise ::ActiveRecord::IrreversibleMigration, 'remove_hypertable_compression_policy is only reversible if given table name and compress period.' # rubocop:disable Layout/LineLength
          end

          [:add_hypertable_compression_policy, args, block]
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

        def invert_add_hypertable_reorder_policy(args, &block)
          [:remove_hypertable_reorder_policy, args, block]
        end

        def invert_remove_hypertable_reorder_policy(args, &block)
          if args.size < 2
            raise ::ActiveRecord::IrreversibleMigration, 'remove_hypertable_reorder_policy is only reversible if given table name and index name.' # rubocop:disable Layout/LineLength
          end

          [:add_hypertable_reorder_policy, args, block]
        end

        def invert_create_continuous_aggregate(args, &block)
          [:drop_continuous_aggregate, args, block]
        end

        def invert_drop_continuous_aggregate(args, &block)
          if args.size < 2
            raise ::ActiveRecord::IrreversibleMigration, 'drop_continuous_aggregate is only reversible if given view name and view query.' # rubocop:disable Layout/LineLength
          end

          [:create_continuous_aggregate, args, block]
        end

        def invert_add_continuous_aggregate_policy(args, &block)
          [:remove_continuous_aggregate_policy, args, block]
        end

        def invert_remove_continuous_aggregate_policy(args, &block)
          if args.size < 4
            raise ::ActiveRecord::IrreversibleMigration, 'remove_continuous_aggregate_policy is only reversible if given view name, start offset, end offset and schedule interval.' # rubocop:disable Layout/LineLength
          end

          [:add_continuous_aggregate_policy, args, block]
        end
      end
    end
  end
end
