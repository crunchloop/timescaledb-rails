# frozen_string_literal: true

require 'spec_helper'

describe Timescaledb::Rails::ContinuousAggregate do
  subject(:continuous_aggregate) { described_class.new(view_name: view) }

  let(:view) { 'continuous_aggregate_view' }

  describe '#refresh!' do
    context 'when called with no dates' do
      it 'manually refreshes the continuous aggregate' do
        expect(ActiveRecord::Base.connection)
          .to receive(:execute).with("CALL refresh_continuous_aggregate('#{view}', NULL, NULL);")

        continuous_aggregate.refresh!
      end
    end

    context 'when called with start date and date_date' do
      context 'when dates are a timestamp' do
        let(:start_time) { 3.days.ago }
        let(:end_time) { 1.day.ago }

        it 'manually refreshes the continuous aggregate' do
          expect(ActiveRecord::Base.connection)
            .to receive(:execute).with("CALL refresh_continuous_aggregate('#{view}', #{start_time}, #{end_time});")

          continuous_aggregate.refresh!(start_time, end_time)
        end
      end

      context 'when dates are a string' do
        let(:start_time) { '2022-01-01' }
        let(:end_time) { '2023-01-01' }

        it 'manually refreshes the continuous aggregate' do
          expect(ActiveRecord::Base.connection)
            .to receive(:execute).with("CALL refresh_continuous_aggregate('#{view}', #{start_time}, #{end_time});")

          continuous_aggregate.refresh!(start_time, end_time)
        end
      end
    end
  end
end
