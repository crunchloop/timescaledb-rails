# frozen_string_literal: true

require 'spec_helper'

describe Timescaledb::Rails::Chunk do
  describe '#compress!' do
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
      # TODO: swap this logic for the `decompress_chunk` method once it's available
      ActiveRecord::Base.connection.execute(
        "SELECT decompress_chunk(c, true) FROM show_chunks('events') c"
      )

      Event.delete_all
    end

    it 'compresses a chunk' do
      chunk.compress!

      expect(chunk.reload).to be_is_compressed
    end

    it 'throws an error if the chunk is already compressed' do
      chunk.compress!

      expect { chunk.compress! }.to raise_error(ActiveRecord::StatementInvalid)
    end
  end
end
