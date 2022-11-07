# frozen_string_literal: true

source 'http://rubygems.org'

gemspec

case ENV.fetch('TEST_RAILS_VERSION', '6.0')
when '7.0'
  gem 'rails', '~> 7.0.1'
when '6.0'
  gem 'rails', '~> 6.0.1'
end

group :test do
  gem 'pg', '>= 1.2'
  gem 'rspec', '>= 3.12'
  gem 'rubocop', '>= 1.39'
  gem 'rubocop-performance', '>= 1.15'
  gem 'rubocop-rails', '>= 2.17'
  gem 'rubocop-rspec', '>= 2.15'
end
