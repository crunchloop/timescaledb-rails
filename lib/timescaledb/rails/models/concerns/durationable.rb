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
          duration_in_seconds =
            if (duration =~ HOUR_MINUTE_SECOND_REGEX).present?
              hours, minutes, seconds = duration.split(':').map(&:to_i)

              (hours.hour + minutes.minute + seconds.second).to_i
            else
              ActiveSupport::Duration.parse(duration).to_i
            end

          ActiveSupport::Duration.build(duration_in_seconds).inspect
        rescue ActiveSupport::Duration::ISO8601Parser::ParsingError
          duration
        end
      end
    end
  end
end
