# frozen_string_literal: true

require 'active_record/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    config.active_record.schema_format = :ruby
    config.active_record.dump_schemas = :all

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults Rails.version[0..2]

    config.logger = Logger.new('/dev/null')
  end
end
