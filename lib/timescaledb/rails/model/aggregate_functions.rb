# frozen_string_literal: true

module Timescaledb
  module Rails
    module Model
      # :nodoc:
      module AggregateFunctions
        def count(alias_name = 'count')
          select("COUNT(1) AS #{alias_name}")
        end

        def avg(column_name, alias_name = 'avg')
          select("AVG(#{column_name}) AS #{alias_name}")
        end

        def sum(column_name, alias_name = 'sum')
          select("SUM(#{column_name}) AS #{alias_name}")
        end

        def min(column_name, alias_name = 'min')
          select("MIN(#{column_name}) AS #{alias_name}")
        end

        def max(column_name, alias_name = 'max')
          select("MAX(#{column_name}) AS #{alias_name}")
        end
      end
    end
  end
end
