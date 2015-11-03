module SlideRule
  class DistanceCalculator
    def initialize(rules)
      @rules = normalize_weights(rules)
    end

    # TODO: Figure this out. Very inefficient!
    # Probably should calculate using a suggestions algorythm
    def group(array)
      array.map do |item|
        {
          item: item,
          matches: (array - [item]).map do |item_cmp|
            {
              match: item_cmp,
              distance: calculate_distance(item, item_cmp)
            }
          end
        }
      end
    end

    def closest_match(obj, array, threshold)
      matches(obj, array, threshold).sort { |match| match[:distance] }.first
    end

    def matches(obj, array, threshold)
      array.map do |item|
        distance = calculate_distance(obj, item)
        next nil unless distance < threshold
        {
          item: item,
          distance: distance
        }
      end.compact
    end

    # All distances represented as 0..1
    #  0 = perfect match
    #  1 = farthest distance
    # Calculate distances for all attributes, then apply weight, and average them out.
    # Rules format:
    # {
    #   :attribute_name => {
    #     :weight => 0.90,
    #     :type => :distance_calculator,
    #   }
    # }
    def calculate_distance(i1, i2)
      @rules.map do |attribute, rule|
        val1 = i1.send(attribute)
        val2 = i2.send(attribute)
        calculator = get_calculator(rule[:type])
        calculator.calculate(val1, val2).to_f * rule[:weight]
      end.reduce(0.0, &:+)
    end

    def get_calculator(calculator)
      return calculator.new if calculator.is_a?(Class)

      klass_name = "#{calculator.to_s.split('_').collect(&:capitalize).join}"
      klass = ::SlideRule::DistanceCalculators.const_get(klass_name)

      fail ArgumentError, "Unable to find calculator #{klass_name}" if klass.nil?

      klass.new
    end

    # Ensures all weights add up to 1.0
    #
    def normalize_weights(rules_hash)
      rules = rules_hash.dup
      weight_total = rules.map { |_attr, rule| rule[:weight] }.reduce(0.0, &:+)
      rules.each do |_attr, rule|
        rule[:weight] = rule[:weight] / weight_total
      end
    end
  end
end
