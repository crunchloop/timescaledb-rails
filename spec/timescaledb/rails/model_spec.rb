# frozen_string_literal: true

require 'spec_helper'

describe Timescaledb::Rails::Model do
  describe '.hypertable_name' do
    context 'when default schema path' do
      it 'returns the expected name' do
        expect(HypertableDefaultSchema.hypertable_name).to eq('payloads')
      end
    end

    context 'when custom schema path' do
      it 'returns the expected name' do
        expect(HypertableCustomSchema.hypertable_name).to eq('events')
      end
    end
  end

  describe '.hypertable_schema' do
    context 'when default schema path' do
      it 'returns the expected schema' do
        expect(HypertableDefaultSchema.hypertable_schema).to eq('public')
      end
    end

    context 'when custom schema path' do
      it 'returns the expected schema' do
        expect(HypertableCustomSchema.hypertable_schema).to eq('tdb')
      end
    end
  end

  describe '.hypertable' do
    context 'when default schema path' do
      it 'returns the expected hypertable record' do
        expected_hypertable = Timescaledb::Rails::Hypertable.find_by(hypertable_name: 'payloads')

        expect(HypertableDefaultSchema.hypertable).to eq(expected_hypertable)
      end
    end

    context 'when custom schema path' do
      it 'returns the expected hypertable record' do
        expected_hypertable = Timescaledb::Rails::Hypertable.find_by(hypertable_name: 'events')

        expect(HypertableCustomSchema.hypertable).to eq(expected_hypertable)
      end
    end

    context 'when non hypertable' do
      it 'returns nil' do
        expect(NonHypertable.hypertable).to be_nil
      end
    end
  end

  describe '.hypertable_jobs' do
    context 'with compression' do
      it 'includes compression job' do
        compress_job = Timescaledb::Rails::Job.policy_compression.find_by(hypertable_name: 'events')

        expect(HypertableWithCompression.hypertable_jobs).to include(compress_job)
      end
    end

    context 'without compression' do
      it 'does not include compression job' do
        expect(HypertableWithoutCompression.hypertable_jobs).to be_empty
      end
    end

    context 'with retention policy' do
      it 'includes retention policy job' do
        retention_job = Timescaledb::Rails::Job.policy_retention.find_by(hypertable_name: 'events')

        expect(HypertableWithCompression.hypertable_jobs).to include(retention_job)
      end
    end

    context 'without retention policy' do
      it 'does not include retention policy job' do
        expect(HypertableWithoutCompression.hypertable_jobs).to be_empty
      end
    end

    context 'when non hypertable' do
      it 'returns empty' do
        expect(NonHypertable.hypertable_jobs).to be_empty
      end
    end
  end

  describe '.hypertable_dimensions' do
    context 'when hypertable' do
      it 'includes time dimension' do
        time_dimension = Timescaledb::Rails::Dimension.find_by(hypertable_name: 'payloads')

        # include matcher was not working with ActiveRecord objects
        expect(StandardHypertable.hypertable_dimensions.map(&:attributes)).to include(time_dimension.attributes)
      end
    end

    context 'when non hypertable' do
      it 'returns empty' do
        expect(NonHypertable.hypertable_dimensions).to be_empty
      end
    end
  end

  describe '.hypertable_compression_settings' do
    context 'with compression' do
      it 'includes all compression settings' do
        expect(HypertableWithCompression.hypertable_compression_settings.map(&:attname))
          .to match_array(%w[event_type name occurred_at recorded_at created_at])
      end
    end

    context 'without compression' do
      it 'does not include compression job' do
        expect(HypertableWithoutCompression.hypertable_compression_settings).to be_empty
      end
    end

    context 'when non hypertable' do
      it 'returns empty' do
        expect(NonHypertable.hypertable_compression_settings).to be_empty
      end
    end
  end
end
