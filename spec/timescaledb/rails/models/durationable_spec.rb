# frozen_string_literal: true

require 'spec_helper'

require 'timescaledb/rails/models/concerns/durationable'

describe Timescaledb::Rails::Models::Durationable do
  subject(:durationable) { durationable_class.new }

  let(:durationable_class) do
    Class.new do
      include Timescaledb::Rails::Models::Durationable
    end
  end

  describe '.parse_duration' do
    context 'when given a duration text' do
      it 'returns the same value' do
        expect(durationable.parse_duration('1 day')).to eq('1 day')
      end
    end

    context 'when given a iso 8601 duration text' do
      it 'returns the expected duration value' do
        expect(durationable.parse_duration('P1Y1D')).to eq('1 year and 1 day')
      end
    end

    context 'when given a HH:MM:SS duration text' do
      it 'returns the expected duration value' do
        expect(durationable.parse_duration('730:29:06')).to eq('1 month')
      end
    end
  end
end
