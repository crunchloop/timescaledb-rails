# frozen_string_literal: true

module Timescaledb
  module Rails
    # :nodoc:
    class Chunk < ::ActiveRecord::Base
      self.table_name = 'timescaledb_information.chunks'
      self.primary_key = 'hypertable_name'

      scope :compressed, -> { where(is_compressed: true) }
      scope :decompressed, -> { where(is_compressed: false) }

      def chunk_full_name
        "#{chunk_schema}.#{chunk_name}"
      end

      def compress!
        ::ActiveRecord::Base.connection.execute(
          "SELECT compress_chunk('#{chunk_full_name}')"
        )
      end
    end
  end
end
