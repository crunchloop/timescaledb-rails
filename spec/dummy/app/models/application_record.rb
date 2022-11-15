# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  if Rails.version.to_i >= 7
    primary_abstract_class
  else
    self.abstract_class = true
  end
end
