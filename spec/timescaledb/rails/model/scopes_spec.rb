# frozen_string_literal: true

require 'spec_helper'

describe Timescaledb::Rails::Model::Scopes do
  after do
    Event.delete_all
  end

  describe '.last_year' do
    let(:two_years_ago_event) { create_event(name: '2 years ago', created_at: 2.years.ago) }
    let(:last_year_event) { create_event(name: 'last year', created_at: 1.year.ago) }
    let(:this_year_event) { create_event(name: 'this year', created_at: Time.current) }

    before do
      two_years_ago_event
      last_year_event
      this_year_event
    end

    it 'includes records from last year' do
      expect(Event.last_year.map(&:name)).to include(last_year_event.name)
    end

    it 'does not include records from this year' do
      expect(Event.last_year.map(&:name)).not_to include(this_year_event.name)
    end

    it 'does not include records older than last year' do
      expect(Event.last_year.map(&:name)).not_to include(two_years_ago_event.name)
    end
  end

  describe '.last_month' do
    let(:two_months_ago_event) { create_event(name: '2 months ago', created_at: 2.months.ago) }
    let(:last_month_event) { create_event(name: 'last month', created_at: 1.month.ago) }
    let(:this_month_event) { create_event(name: 'this month', created_at: Time.current) }

    before do
      two_months_ago_event
      last_month_event
      this_month_event
    end

    it 'includes records from last month' do
      expect(Event.last_month.map(&:name)).to include(last_month_event.name)
    end

    it 'does not include records from this month' do
      expect(Event.last_month.map(&:name)).not_to include(this_month_event.name)
    end

    it 'does not include records older than last month' do
      expect(Event.last_month.map(&:name)).not_to include(two_months_ago_event.name)
    end
  end

  describe '.last_week' do
    let(:two_weeks_ago_event) { create_event(name: '2 weeks ago', created_at: 2.weeks.ago) }
    let(:last_week_event) { create_event(name: 'last week', created_at: 1.week.ago) }
    let(:this_week_event) { create_event(name: 'this week', created_at: Time.current) }

    before do
      two_weeks_ago_event
      last_week_event
      this_week_event
    end

    it 'includes records from last week' do
      expect(Event.last_week.map(&:name)).to include(last_week_event.name)
    end

    it 'does not include records from this week' do
      expect(Event.last_week.map(&:name)).not_to include(this_week_event.name)
    end

    it 'does not include records older than last week' do
      expect(Event.last_week.map(&:name)).not_to include(two_weeks_ago_event.name)
    end
  end

  describe '.this_year' do
    let(:last_year_event) { create_event(name: 'last year', created_at: 1.year.ago) }
    let(:this_year_event) { create_event(name: 'this year', created_at: Time.current) }

    before do
      last_year_event
      this_year_event
    end

    it 'includes records from this year' do
      expect(Event.this_year.map(&:name)).to include(this_year_event.name)
    end

    it 'does not include records from last year' do
      expect(Event.this_year.map(&:name)).not_to include(last_year_event.name)
    end
  end

  describe '.this_month' do
    let(:last_month_event) { create_event(name: 'last month', created_at: 1.month.ago) }
    let(:this_month_event) { create_event(name: 'this month', created_at: Time.current) }

    before do
      last_month_event
      this_month_event
    end

    it 'includes records from this month' do
      expect(Event.this_month.map(&:name)).to include(this_month_event.name)
    end

    it 'does not include records from last month' do
      expect(Event.this_month.map(&:name)).not_to include(last_month_event.name)
    end
  end

  describe '.this_week' do
    let(:last_week_event) { create_event(name: 'last week', created_at: 1.week.ago) }
    let(:this_week_event) { create_event(name: 'this week', created_at: Time.current) }

    before do
      last_week_event
      this_week_event
    end

    it 'includes records from this week' do
      expect(Event.this_week.map(&:name)).to include(this_week_event.name)
    end

    it 'does not include records from last week' do
      expect(Event.this_week.map(&:name)).not_to include(last_week_event.name)
    end
  end

  describe '.yesterday' do
    let(:yesterday_event) { create_event(name: 'yesterday', created_at: 1.day.ago) }
    let(:today_event) { create_event(name: 'today', created_at: Time.current) }
    let(:tomorrow_event) { create_event(name: 'tomorrow', created_at: 1.day.from_now) }

    before do
      yesterday_event
      today_event
      tomorrow_event
    end

    it 'includes records from yesterday' do
      expect(Event.yesterday.map(&:name)).to include(yesterday_event.name)
    end

    it 'does not include records from today' do
      expect(Event.yesterday.map(&:name)).not_to include(today_event.name)
    end

    it 'does not include records from tomorrow' do
      expect(Event.yesterday.map(&:name)).not_to include(tomorrow_event.name)
    end
  end

  describe '.today' do
    let(:yesterday_event) { create_event(name: 'yesterday', created_at: 1.day.ago) }
    let(:today_event) { create_event(name: 'today', created_at: Time.current) }
    let(:tomorrow_event) { create_event(name: 'tomorrow', created_at: 1.day.from_now) }

    before do
      yesterday_event
      today_event
      tomorrow_event
    end

    it 'includes records from today' do
      expect(Event.today.map(&:name)).to include(today_event.name)
    end

    it 'does not include records from yesterday' do
      expect(Event.today.map(&:name)).not_to include(yesterday_event.name)
    end

    it 'does not include records from tomorrow' do
      expect(Event.today.map(&:name)).not_to include(tomorrow_event.name)
    end
  end
end
