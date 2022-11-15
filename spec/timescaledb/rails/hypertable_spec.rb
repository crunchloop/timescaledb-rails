# frozen_string_literal: true

require 'spec_helper'

describe Timescaledb::Rails::Hypertable do
  it 'includes events hypertable' do
    expect(described_class.where(hypertable_name: 'events')).to be_present
  end

  it 'does not include non hypertable event_types' do
    expect(described_class.where(hypertable_name: 'event_types')).to be_blank
  end
end
