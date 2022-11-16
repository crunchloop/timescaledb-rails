#!/bin/bash
set -e

# Install ruby dependencies
bundle check || bundle install

# Move to dummy rails application
cd spec/dummy

# Fix BUNDLE_GEMFILE path
export BUNDLE_GEMFILE=../../${BUNDLE_GEMFILE}
# Disable db env check
export DISABLE_DATABASE_ENVIRONMENT_CHECK=1

# Setup dummy app test database
export RAILS_ENV=test
bundle exec rake db:drop
bundle exec rake db:create
bundle exec rake db:migrate

# Return back to gem root path
cd ../..
