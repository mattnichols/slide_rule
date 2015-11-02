module SlideRule
  module DistanceCalculators
    class DayOfYear
      DAYS_IN_YEAR = 365

      def calculate(date_1, date_2)
        date_1 = Date.parse(date_1) unless date_1.is_a?(::Date) || date_1.is_a?(::Time)
        date_2 = Date.parse(date_2) unless date_2.is_a?(::Date) || date_2.is_a?(::Time)

        date_1 = date_1.to_date if date_1.is_a?(::Time)
        date_2 = date_2.to_date if date_2.is_a?(::Time)

        days_apart = (date_1.mjd - date_2.mjd).abs

        return 1 if days_apart >= DAYS_IN_YEAR

        distance = days_apart.to_f / DAYS_IN_YEAR
        distance.round(2)
      end
    end
  end
end
