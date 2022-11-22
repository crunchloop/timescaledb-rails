# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('lib', __dir__))

require 'timescaledb/rails/version'

Gem::Specification.new do |s|
  s.name = 'timescaledb-rails'
  s.version = Timescaledb::Rails::VERSION
  s.metadata['rubygems_mfa_required'] = 'true'

  s.homepage = 'http://github.com/crunchloop/timescaledb-rails'
  s.summary  = 'TimescaleDB Rails integration'
  s.license  = 'MIT'

  s.files = Dir['README.md', 'lib/**/*.rb', 'LICENSE']

  s.required_ruby_version = '>= 2.6'

  s.add_dependency 'rails', '>= 6.0'

  s.add_development_dependency 'pg', '~> 1.2'
  s.add_development_dependency 'rspec', '~> 3.12'
  s.add_development_dependency 'rubocop', '~> 1.39'
  s.add_development_dependency 'rubocop-performance', '~> 1.15'
  s.add_development_dependency 'rubocop-rails', '~> 2.17'
  s.add_development_dependency 'rubocop-rspec', '~> 2.15'

  s.authors = ['Iván Etchart', 'Santiago Doldán']
  s.email = 'oss@crunchloop.io'
end
