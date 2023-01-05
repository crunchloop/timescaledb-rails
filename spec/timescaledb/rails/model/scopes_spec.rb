# frozen_string_literal: true

require 'spec_helper'

describe Timescaledb::Rails::Model::Scopes do
  describe '.last_year' do
    let!(:two_years_ago_payload) { create_payload(data: 'two years ago', created_at: 2.years.ago) }
    let!(:last_year_payload) { create_payload(data: 'last year', created_at: 1.year.ago) }
    let!(:this_year_payload) { create_payload(data: 'this year', created_at: Time.current) }

    after do
      two_years_ago_payload.destroy
      last_year_payload.destroy
      this_year_payload.destroy
    end

    it 'includes records from last year' do
      expect(Payload.last_year.map(&:id)).to include(last_year_payload.id)
    end

    it 'does not include records from this year' do
      expect(Payload.last_year.map(&:id)).not_to include(this_year_payload.id)
    end

    it 'does not include records older than last year' do
      expect(Payload.last_year.map(&:id)).not_to include(two_years_ago_payload.id)
    end
  end

  describe '.last_month' do
    let!(:two_months_ago_payload) { create_payload(data: 'two months ago', created_at: 2.months.ago) }
    let!(:last_month_payload) { create_payload(data: 'last month', created_at: 1.month.ago) }
    let!(:this_month_payload) { create_payload(data: 'this month', created_at: Time.current) }

    after do
      two_months_ago_payload.destroy
      last_month_payload.destroy
      this_month_payload.destroy
    end

    it 'includes records from last month' do
      expect(Payload.last_month.map(&:id)).to include(last_month_payload.id)
    end

    it 'does not include records from this month' do
      expect(Payload.last_month.map(&:id)).not_to include(this_month_payload.id)
    end

    it 'does not include records older than last month' do
      expect(Payload.last_month.map(&:id)).not_to include(two_months_ago_payload.id)
    end
  end

  describe '.last_week' do
    let!(:two_weeks_ago_payload) { create_payload(data: 'two weeks ago', created_at: 2.weeks.ago) }
    let!(:last_week_payload) { create_payload(data: 'last week', created_at: 1.week.ago) }
    let!(:this_week_payload) { create_payload(data: 'this week', created_at: Time.current) }

    after do
      two_weeks_ago_payload.destroy
      last_week_payload.destroy
      this_week_payload.destroy
    end

    it 'includes records from last week' do
      expect(Payload.last_week.map(&:id)).to include(last_week_payload.id)
    end

    it 'does not include records from this week' do
      expect(Payload.last_week.map(&:id)).not_to include(this_week_payload.id)
    end

    it 'does not include records older than last week' do
      expect(Payload.last_week.map(&:id)).not_to include(two_weeks_ago_payload.id)
    end
  end

  describe '.this_year' do
    let!(:last_year_payload) { create_payload(data: 'last year', created_at: 1.year.ago) }
    let!(:this_year_payload) { create_payload(data: 'this year', created_at: Time.current) }

    after do
      last_year_payload.destroy
      this_year_payload.destroy
    end

    it 'includes records from this year' do
      expect(Payload.this_year.map(&:id)).to include(this_year_payload.id)
    end

    it 'does not include records from last year' do
      expect(Payload.this_year.map(&:id)).not_to include(last_year_payload.id)
    end
  end

  describe '.this_month' do
    let!(:last_month_payload) { create_payload(data: 'last month', created_at: 1.month.ago) }
    let!(:this_month_payload) { create_payload(data: 'this month', created_at: Time.current) }

    after do
      last_month_payload.destroy
      this_month_payload.destroy
    end

    it 'includes records from this month' do
      expect(Payload.this_month.map(&:id)).to include(this_month_payload.id)
    end

    it 'does not include records from last month' do
      expect(Payload.this_month.map(&:id)).not_to include(last_month_payload.id)
    end
  end

  describe '.this_week' do
    let!(:last_week_payload) { create_payload(data: 'last week', created_at: 1.week.ago) }
    let!(:this_week_payload) { create_payload(data: 'this week', created_at: Time.current) }

    after do
      last_week_payload.destroy
      this_week_payload.destroy
    end

    it 'includes records from this week' do
      expect(Payload.this_week.map(&:id)).to include(this_week_payload.id)
    end

    it 'does not include records from last week' do
      expect(Payload.this_week.map(&:id)).not_to include(last_week_payload.id)
    end
  end

  describe '.yesterday' do
    let!(:yesterday_payload) { create_payload(data: 'yesterday', created_at: 1.day.ago) }
    let!(:today_payload) { create_payload(data: 'today', created_at: Time.current) }
    let!(:tomorrow_payload) { create_payload(data: 'tomorrow', created_at: 1.day.from_now) }

    after do
      yesterday_payload.destroy
      today_payload.destroy
      tomorrow_payload.destroy
    end

    it 'includes records from yesterday' do
      expect(Payload.yesterday.map(&:id)).to include(yesterday_payload.id)
    end

    it 'does not include records from today' do
      expect(Payload.yesterday.map(&:id)).not_to include(today_payload.id)
    end

    it 'does not include records from tomorrow' do
      expect(Payload.yesterday.map(&:id)).not_to include(tomorrow_payload.id)
    end
  end

  describe '.today' do
    let!(:yesterday_payload) { create_payload(data: 'yesterday', created_at: 1.day.ago) }
    let!(:today_payload) { create_payload(data: 'today', created_at: Time.current) }
    let!(:tomorrow_payload) { create_payload(data: 'tomorrow', created_at: 1.day.from_now) }

    after do
      yesterday_payload.destroy
      today_payload.destroy
      tomorrow_payload.destroy
    end

    it 'includes records from today' do
      expect(Payload.today.map(&:id)).to include(today_payload.id)
    end

    it 'does not include records from yesterday' do
      expect(Payload.today.map(&:id)).not_to include(yesterday_payload.id)
    end

    it 'does not include records from tomorrow' do
      expect(Payload.today.map(&:id)).not_to include(tomorrow_payload.id)
    end
  end

  describe '.after' do
    let!(:yesterday_payload) { create_payload(data: 'yesterday', created_at: 1.day.ago) }
    let!(:today_payload) { create_payload(data: 'today', created_at: Time.current) }
    let!(:tomorrow_payload) { create_payload(data: 'tomorrow', created_at: 1.day.from_now) }

    after do
      yesterday_payload.destroy
      today_payload.destroy
      tomorrow_payload.destroy
    end

    it 'includes records after given time' do
      expect(Payload.after(1.hour.ago).map(&:id)).to match_array([today_payload.id, tomorrow_payload.id])
    end
  end

  describe '.at_time' do
    let!(:yesterday_payload) { create_payload(data: 'yesterday', created_at: 1.day.ago) }
    let!(:today_payload) { create_payload(data: 'today', created_at: Time.current) }
    let!(:tomorrow_payload) { create_payload(data: 'tomorrow', created_at: 1.day.from_now) }

    after do
      yesterday_payload.destroy
      today_payload.destroy
      tomorrow_payload.destroy
    end

    it 'includes records at given time' do
      expect(Payload.at_time(yesterday_payload.created_at).map(&:id)).to match_array([yesterday_payload.id])
    end
  end

  describe '.between' do
    let!(:yesterday_payload) { create_payload(data: 'yesterday', created_at: 1.day.ago) }
    let!(:today_payload) { create_payload(data: 'today', created_at: Time.current) }
    let!(:tomorrow_payload) { create_payload(data: 'tomorrow', created_at: 1.day.from_now) }

    after do
      yesterday_payload.destroy
      today_payload.destroy
      tomorrow_payload.destroy
    end

    it 'includes records between given time' do
      expect(Payload.between(Time.current.beginning_of_day, Time.current.end_of_day).map(&:id))
        .to match_array([today_payload.id])
    end
  end
end
