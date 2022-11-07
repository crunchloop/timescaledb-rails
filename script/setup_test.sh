#!/bin/bash
set -e

# Install ruby dependencies
bundle check || bundle install

# Move to dummy rails application
cd spec/dummy

# Setup dummy app test database
export RAILS_ENV=test
bundle exec rake db:drop
bundle exec rake db:create
bundle exec rake db:migrate

# Return back to gem root path
cd ../..
