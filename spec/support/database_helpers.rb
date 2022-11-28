# frozen_string_literal: true

require 'fileutils'

module Timescaledb
  module Rails
    module DatabaseHelpers
      def database_configuration
        ::Rails.application.config_for(:database)
      end

      def database_structure_name
        'test_structure.sql'
      end

      def database_structure
        File.read(database_structure_name)
      end

      def database_delete_structure_file!
        FileUtils.rm_f(database_structure_name)
      end
    end
  end
end
