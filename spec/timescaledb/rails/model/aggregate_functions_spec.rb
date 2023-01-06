# frozen_string_literal: true

require 'spec_helper'

describe Timescaledb::Rails::Model::AggregateFunctions do
  subject(:aggregate) { Event.extending(described_class) }

  describe '.avg' do
    it 'returns expected select statement' do
      expect(aggregate.avg(:created_at).to_sql).to include('SELECT AVG(created_at) AS avg FROM')
    end

    context 'when passing custom alias name' do
      it 'returns expected select statement' do
        expect(aggregate.avg(:created_at, :foo).to_sql).to include('SELECT AVG(created_at) AS foo FROM')
      end
    end
  end

  describe '.sum' do
    it 'returns expected select statement' do
      expect(aggregate.sum(:created_at).to_sql).to include('SELECT SUM(created_at) AS sum FROM')
    end

    context 'when passing custom alias name' do
      it 'returns expected select statement' do
        expect(aggregate.sum(:created_at, :foo).to_sql).to include('SELECT SUM(created_at) AS foo FROM')
      end
    end
  end

  describe '.min' do
    it 'returns expected select statement' do
      expect(aggregate.min(:created_at).to_sql).to include('SELECT MIN(created_at) AS min FROM')
    end

    context 'when passing custom alias name' do
      it 'returns expected select statement' do
        expect(aggregate.min(:created_at, :foo).to_sql).to include('SELECT MIN(created_at) AS foo FROM')
      end
    end
  end

  describe '.max' do
    it 'returns expected select statement' do
      expect(aggregate.max(:created_at).to_sql).to include('SELECT MAX(created_at) AS max FROM')
    end

    context 'when passing custom alias name' do
      it 'returns expected select statement' do
        expect(aggregate.max(:created_at, :foo).to_sql).to include('SELECT MAX(created_at) AS foo FROM')
      end
    end
  end

  describe '.count' do
    it 'returns expected select statement' do
      expect(aggregate.count.to_sql).to include('SELECT COUNT(1) AS count FROM')
    end

    context 'when passing custom alias name' do
      it 'returns expected select statement' do
        expect(aggregate.count(:foo).to_sql).to include('SELECT COUNT(1) AS foo FROM')
      end
    end
  end
end
