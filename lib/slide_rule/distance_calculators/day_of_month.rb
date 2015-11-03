module SlideRule
  module DistanceCalculators
    class DayOfMonth
      MAX_DAYS = 15

      #
      # Calculates distance using 15 as the max point.
      #   Does not take into account the number of days in the actual month being considered.
      #
      def calculate(first, second)
        first = cleanse_date(first)
        second = cleanse_date(second)

        difference_in_days(first, second).to_f / MAX_DAYS
      end

      def difference_in_days(first, second)
        distance = (first.mday - second.mday).abs
        return distance if distance <= MAX_DAYS
        MAX_DAYS - (distance - MAX_DAYS)
      end

      private

      def cleanse_date(date)
        date = Date.parse(date) unless date.is_a?(::Date) || date.is_a?(::Time)
        date = date.to_date if date.is_a?(::Time)

        date
      end
    end
  end
end
