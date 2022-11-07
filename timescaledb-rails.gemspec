$:.unshift File.expand_path('../lib', __FILE__)

require 'timescaledb/rails/version'

Gem::Specification.new do |s|
  s.name = 'timescaledb-rails'
  s.version = Timescaledb::Rails::VERSION

  s.homepage = 'http://github.com/crunchloop/timescaledb-rails'
  s.summary  = 'TimescaleDB Rails integration'
  s.license  = 'MIT'

  s.files = Dir['README.md', 'lib/**/*.rb', 'LICENSE']

  s.required_ruby_version = '>= 2.5'

  s.authors = ['Iván Etchart', 'Santiago Doldán']
  s.email  = 'oss@crunchloop.io'
end
