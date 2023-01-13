# frozen_string_literal: true

module Timescaledb
  module Rails
    module Models
      # :nodoc:
      module Durationable
        extend ActiveSupport::Concern

        HOUR_MINUTE_SECOND_REGEX = /^\d+:\d+:\d+$/.freeze

        # @return [String]
        def parse_duration(duration)
          duration_in_seconds = duration_in_seconds(duration)

          duration_to_interval(
            ActiveSupport::Duration.build(duration_in_seconds)
          )
        rescue ActiveSupport::Duration::ISO8601Parser::ParsingError
          duration
        end

        private

        # Converts different interval formats into seconds.
        #
        #   duration_in_seconds('P1D')      #=> 86400
        #   duration_in_seconds('24:00:00') #=> 86400
        #   duration_in_seconds(1.day)      #=> 86400
        #
        # @param [ActiveSupport::Duration|String] duration
        # @return [Integer]
        def duration_in_seconds(duration)
          return duration.to_i if duration.is_a?(ActiveSupport::Duration)

          if (duration =~ HOUR_MINUTE_SECOND_REGEX).present?
            hours, minutes, seconds = duration.split(':').map(&:to_i)

            (hours.hour + minutes.minute + seconds.second).to_i
          else
            ActiveSupport::Duration.parse(duration).to_i
          end
        end

        # Converts given duration into a human interval readable format.
        #
        #   duration_to_interval(1.day)              #=> '1 day'
        #   duration_to_interval(2.weeks + 6.days)   #=> '20 days'
        #   duration_to_interval(1.years + 3.months) #=> '1 year 3 months'
        #
        # @param [ActiveSupport::Duration] duration
        # @return [String]
        def duration_to_interval(duration)
          parts = duration.parts

          # Combine days and weeks if both present
          #
          #   "1 week 2 days" => "9 days"
          parts[:days] += parts.delete(:weeks) * 7 if parts.key?(:weeks) && parts.key?(:days)

          parts.map do |(unit, quantity)|
            "#{quantity} #{humanize_duration_unit(unit.to_s, quantity)}"
          end.join(' ')
        end

        # Pluralize or singularize given duration unit based on given count.
        #
        # @param [String] duration_unit
        # @param [Integer] count
        def humanize_duration_unit(duration_unit, count)
          count > 1 ? duration_unit.pluralize : duration_unit.singularize
        end
      end
    end
  end
end
