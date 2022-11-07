# frozen_string_literal: true

require 'spec_helper'

describe Timescaledb::Rails::Dimension do
  it 'includes events time dimension interval' do
    time_dimension = described_class.time.where(hypertable_name: 'events').first

    expected_interval = Rails.version.to_i >= 7 ? 2.days : 2.days.inspect

    expect(time_dimension.time_interval).to eq(expected_interval)
  end

  it 'includes events time dimension column name' do
    time_dimension = described_class.time.where(hypertable_name: 'events').first

    expect(time_dimension.column_name).to eq('created_at')
  end
end
