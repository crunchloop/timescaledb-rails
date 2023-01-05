# frozen_string_literal: true

require 'spec_helper'

describe Timescaledb::Rails::Model::Hyperfunctions do
  describe '.time_bucket' do
    let!(:january_2022_payload) do
      create_payload(data: 'January payload 2022', created_at: DateTime.parse('01/01/2022'))
    end

    let!(:march_2022_payload) do
      create_payload(data: 'March payload 2022', created_at: DateTime.parse('03/01/2022'))
    end

    after do
      january_2022_payload.destroy
      march_2022_payload.destroy
    end

    it 'extends AggregateFunctions module' do
      result = Payload.time_bucket(1.day)

      expect(result.extending_values).to include(Timescaledb::Rails::Model::AggregateFunctions)
    end

    context 'when the date column is not specified' do
      context 'when the interval is a string' do
        let(:interval) { '1 day' }

        it 'returns an active record relation' do
          result = Payload.time_bucket(interval)

          expect(result).to be_a(ActiveRecord::Relation)
        end
      end

      context 'when the interval is a duration' do
        let(:interval) { 1.day }

        it 'uses the default date column' do
          result = Payload.time_bucket(interval)

          expect(result.to_sql).to include("SELECT time_bucket('1 day', created_at) as time_bucket")
        end

        it 'returns an active record relation' do
          result = Payload.time_bucket(interval)

          expect(result).to be_a(ActiveRecord::Relation)
        end
      end

      context 'when interval is larger than the time range between the records' do
        let(:interval) { 1.year }

        it 'returns a single record' do
          result = Payload.time_bucket(interval)

          expect(result.to_a.size).to eq(1)
        end
      end

      context 'when interval is smaller than the time range between the records' do
        let(:interval) { 1.hour }

        it 'returns multiple records' do
          result = Payload.time_bucket(interval)

          expect(result.to_a.size).to eq(2)
        end
      end
    end

    context 'when the date column is specified' do
      let(:interval) { '1 day' }
      let(:date_column) { :recorded_at }

      it 'uses the specified date column' do
        result = Payload.time_bucket(interval, date_column)

        expect(result.to_sql).to include("SELECT time_bucket('1 day', #{date_column}) as time_bucket")
      end

      context 'when the interval is a string' do
        let(:interval) { '1 day' }
        let(:date_column) { :recorded_at }

        it 'returns an active record relation' do
          result = Payload.time_bucket(interval, date_column)

          expect(result).to be_a(ActiveRecord::Relation)
        end
      end

      context 'when the interval is a duration' do
        let(:interval) { 1.day }
        let(:date_column) { :recorded_at }

        it 'returns an active record relation' do
          result = Payload.time_bucket(interval, date_column)

          expect(result).to be_a(ActiveRecord::Relation)
        end
      end
    end

    context 'when the date column is invalid' do
      let(:interval) { 1.day }
      let(:date_column) { 'invalid_column' }

      it 'raises an error' do
        result = Payload.time_bucket(interval, date_column)

        expect { result.inspect }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end

    context 'when the interval is invalid' do
      let(:interval) { 'invalid interval' }

      it 'raises an error' do
        result = Payload.time_bucket(interval)

        expect { result.inspect }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end
end
