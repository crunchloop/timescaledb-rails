# frozen_string_literal: true

require 'spec_helper'

describe Timescaledb::Rails::Chunk do
  let(:hypertable) { Timescaledb::Rails::Hypertable.find_by(hypertable_name: 'payloads') }
  let(:chunk) { described_class.new(hypertable: hypertable, chunk_name: 'name', chunk_schema: 'schema') }

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

  describe '#reorder!' do
    context 'when no index is provided' do
      context 'when no reorder policy is set' do
        it 'raises an ArgumentError' do
          expect { chunk.reorder! }.to raise_error(ArgumentError)
        end
      end

      context 'when a reorder policy is set' do
        let(:hypertable) { Timescaledb::Rails::Hypertable.find_by(hypertable_name: 'events') }

        it 'calls reorder_chunk without the index' do
          expect(ActiveRecord::Base.connection).to receive(:execute).with(
            "SELECT reorder_chunk('#{chunk.chunk_full_name}', '#{hypertable.reorder_policy_index_name}')"
          )

          chunk.reorder!
        end
      end
    end

    context 'when an index is provided' do
      let(:index) { 'index' }

      it 'calls reorder_chunk with the index' do
        expect(ActiveRecord::Base.connection)
          .to receive(:execute).with("SELECT reorder_chunk('#{chunk.chunk_full_name}', '#{index}')")

        chunk.reorder!(index)
      end
    end

    context 'when wrong index is provided' do
      let(:index) { 'index' }

      it 'raises an error' do
        expect { chunk.reorder!(index) }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end
end
