module SlideRule
  module DistanceCalculators
    class Levenshtein
      def calculate(first, second)
        distance = ::Vladlev.distance(first, second).to_f

        # Lower bound is difference in length
        # distance = matrix.last.last.to_f - (first.length - second.length).abs

        # Upper bound is length of longest string
        # This will decrease distance more for longer strings.
        distance / ([first.length, second.length].max)
      end
    end
  end
end
