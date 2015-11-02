module SlideRule
  module DistanceCalculators
    class DayOfMonth
      MAX_DAYS = 15

      #
      # Calculates distance using 15 as the max point.
      #   Does not take into account the number of days in the actual month being considered.
      #
      def calculate(first, second)
        first = Date.parse(first) unless first.is_a?(::Date) || first.is_a?(::Time)
        second = Date.parse(second) unless second.is_a?(::Date) || second.is_a?(::Time)

        first = first.to_date if first.is_a?(::Time)
        second = second.to_date if second.is_a?(::Time)

        difference_in_days(first, second).to_f / MAX_DAYS
      end

      def difference_in_days(first, second)
        distance = (first.mday - second.mday).abs
        return distance if distance <= MAX_DAYS
        MAX_DAYS - (distance - MAX_DAYS)
      end
    end
  end
end
