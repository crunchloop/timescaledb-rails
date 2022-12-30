# frozen_string_literal: true

require 'spec_helper'

describe Timescaledb::Rails::Chunk do
  let(:chunk) { described_class.new(chunk_name: 'name', chunk_schema: 'schema') }

  describe '#compress!' do
    it 'compresses the chunk' do
      expect(ActiveRecord::Base.connection)
        .to receive(:execute).with("SELECT compress_chunk('#{chunk.chunk_full_name}')")

      chunk.compress!
    end
  end

  describe '#decompress!' do
    it 'decompresses a chunk' do
      expect(ActiveRecord::Base.connection)
        .to receive(:execute).with("SELECT decompress_chunk('#{chunk.chunk_full_name}')")

      chunk.decompress!
    end
  end
end
