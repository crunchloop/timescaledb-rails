# frozen_string_literal: true

require 'spec_helper'

describe Timescaledb::Rails::Chunk do
  let(:today_event) do
    Event.create(name: 'today', created_at: Time.current, occurred_at: 1.hour.ago, recorded_at: Time.current)
  end

  let(:last_month_event) do
    Event.create(name: 'last month', created_at: 1.month.ago, occurred_at: 1.month.ago, recorded_at: 1.month.ago)
  end

  let(:chunk) { Event.hypertable.chunks.order(:range_end).last }

  before do
    today_event
    last_month_event
  end

  after do
    Event.hypertable.chunks.compressed.map(&:decompress!)

    Event.delete_all
  end

  describe '#compress!' do
    context 'when chunk is decompressed' do
      it 'compresses a chunk' do
        chunk.compress!

        expect(chunk.reload).to be_is_compressed
      end
    end

    context 'when chunk is already compressed' do
      before { chunk.compress! }

      it 'throws an error when trying to compress' do
        expect { chunk.compress! }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end

  describe '#decompress!' do
    context 'when chunk is compressed' do
      before { chunk.compress! }

      it 'decompresses a chunk' do
        chunk.decompress!

        expect(chunk.reload).not_to be_is_compressed
      end
    end

    context 'when there is no compressed chunk' do
      it 'throws an error when trying to decompress' do
        expect { chunk.decompress! }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end
end
