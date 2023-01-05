# frozen_string_literal: true

require 'spec_helper'

describe Timescaledb::Rails::Model::FinderMethods do
  let!(:today_payload) { create_payload(data: 'today', created_at: Time.current) }

  after do
    today_payload.destroy
  end

  describe '.find' do
    it 'prints expected warning' do
      expect(Payload)
        .to receive(:warn)
        .with('WARNING: Calling `.find` without filtering by `created_at` could cause performance issues, use built-in find_(at_time|between|after) methods for more performant results.')  # rubocop:disable Layout/LineLength

      Payload.find(today_payload.id)
    end
  end

  describe '.find_at_time' do
    context 'when primary key and time matches' do
      it 'returns expected record' do
        result = Payload.find_at_time(today_payload.id, today_payload.created_at)

        expect(result).to eq(today_payload)
      end
    end

    context 'when only primary key matches' do
      it 'raises not found error' do
        expect do
          Payload.find_at_time(today_payload.id, 1.day.ago)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when only time matches' do
      it 'raises not found error' do
        expect do
          Payload.find_at_time(-1, today_payload.created_at)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '.find_between' do
    context 'when primary key and time matches' do
      it 'returns expected record' do
        result = Payload.find_between(today_payload.id, 1.hour.ago, 1.hour.from_now)

        expect(result).to eq(today_payload)
      end
    end

    context 'when only primary key matches' do
      it 'raises not found error' do
        expect do
          Payload.find_between(today_payload.id, 1.hour.from_now, 2.hours.from_now)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when only time matches' do
      it 'raises not found error' do
        expect do
          Payload.find_between(-1, 1.hour.ago, 1.hour.from_now)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '.find_after' do
    context 'when primary key and time matches' do
      it 'returns expected record' do
        result = Payload.find_after(today_payload.id, 1.hour.ago)

        expect(result).to eq(today_payload)
      end
    end

    context 'when only primary key matches' do
      it 'raises not found error' do
        expect do
          Payload.find_after(today_payload.id, 1.hour.from_now)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when only time matches' do
      it 'raises not found error' do
        expect do
          Payload.find_after(-1, 1.hour.ago)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
