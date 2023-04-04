# frozen_string_literal: true

module Timescaledb
  module Rails
    # :nodoc:
    class Chunk < ApplicationRecord
      self.table_name = 'timescaledb_information.chunks'
      self.primary_key = 'hypertable_name'

      belongs_to :hypertable, foreign_key: 'hypertable_name', class_name: 'Timescaledb::Rails::Hypertable'

      scope :compressed, -> { where(is_compressed: true) }
      scope :decompressed, -> { where(is_compressed: false) }

      def chunk_full_name
        "#{chunk_schema}.#{chunk_name}"
      end

      def compress!
        self.class.connection.execute(
          "SELECT compress_chunk('#{chunk_full_name}')"
        )
      end

      def decompress!
        self.class.connection.execute(
          "SELECT decompress_chunk('#{chunk_full_name}')"
        )
      end

      # @param index [String] The name of the index to order by
      #
      def reorder!(index = nil)
        if index.blank? && !hypertable.reorder?
          raise ArgumentError, 'Index name is required if reorder policy is not set'
        end

        index ||= hypertable.reorder_policy_index_name

        options = ["'#{chunk_full_name}'"]
        options << "'#{index}'" if index.present?

        self.class.connection.execute(
          "SELECT reorder_chunk(#{options.join(', ')})"
        )
      end
    end
  end
end
