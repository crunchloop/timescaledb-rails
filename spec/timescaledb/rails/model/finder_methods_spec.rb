# frozen_string_literal: true

require 'spec_helper'

describe Timescaledb::Rails::Model::FinderMethods do
  describe 'find methods' do
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

  describe 'first and last methods' do
    let!(:first_payload) { create_payload(data: '1', created_at: DateTime.parse('01/01/2020')) }
    let!(:second_payload) { create_payload(data: '2', created_at: DateTime.parse('01/01/2023')) }
    let!(:third_payload) { create_payload(data: '3', created_at: DateTime.parse('02/02/2023')) }

    after do
      first_payload.destroy
      second_payload.destroy
      third_payload.destroy
    end

    describe '.first_for_hypertable' do
      describe 'using first_for_hypertable on a hypertable model' do
        context 'when called on the model' do
          it 'returns expected record' do
            result = Payload.first_for_hypertable(:data, :created_at)

            expect(result.map(&:first)).to eq([first_payload.data])
          end
        end

        context 'when called on a relation' do
          it 'returns expected record' do
            result = Payload.where(data: '1').first_for_hypertable(:data, :created_at)

            expect(result.map(&:first)).to eq([first_payload.data])
          end
        end

        context 'when applied to a time bucket' do
          it 'returns expected records' do
            result = Payload.time_bucket(1.year).first_for_hypertable(:data, :created_at)

            expect(result.map(&:first)).to eq([first_payload.data, second_payload.data])
          end
        end
      end

      describe 'using first_for_hypertable on a non-hypertable model' do
        it 'raises error' do
          expect do
            NonHypertable.first_for_hypertable(:data, :created_at)
          end.to raise_error("No hypertable found for #{NonHypertable}")
        end
      end
    end

    describe '.last_for_hypertable' do
      describe 'using last_for_hypertable on a hypertable model' do
        context 'when called on the model' do
          it 'returns expected record' do
            result = Payload.last_for_hypertable(:data, :created_at)

            expect(result.map(&:last)).to eq([third_payload.data])
          end
        end

        context 'when called on a relation' do
          it 'returns expected record' do
            result = Payload.where(data: '3').last_for_hypertable(:data, :created_at)

            expect(result.map(&:last)).to eq([third_payload.data])
          end
        end

        context 'when applied to a time bucket' do
          it 'returns expected records' do
            result = Payload.time_bucket(1.year).last_for_hypertable(:data, :created_at)

            expect(result.map(&:last)).to eq([first_payload.data, third_payload.data])
          end
        end
      end

      describe 'using last_for_hypertable on a non-hypertable model' do
        it 'raises error' do
          expect do
            NonHypertable.last_for_hypertable(:data, :created_at)
          end.to raise_error("No hypertable found for #{NonHypertable}")
        end
      end
    end
  end
end
