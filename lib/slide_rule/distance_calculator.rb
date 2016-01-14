module SlideRule
  class DistanceCalculator
    attr_accessor :rules

    def initialize(rules)
      @rules = prepare_rules(rules)
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

    def closest_match(obj, array, threshold = 1.0)
      matches(obj, array, threshold).sort_by { |match| match[:distance] }.first
    end

    def closest_matching_item(obj, array, threshold = 1.0)
      match = closest_match(obj, array, threshold)
      return nil if match.nil?

      match[:item]
    end

    def is_match?(obj_1, obj_2, threshold)
      distance = calculate_distance(obj_1, obj_2)
      distance < threshold
    end

    def matches(obj, array, threshold)
      array.map do |item|
        distance = calculate_distance(obj, item)
        next nil unless distance <= threshold
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
    #     :calculator => :distance_calculator,
    #   }
    # }
    def calculate_distance(i1, i2)
      calculate_weighted_distances(i1, i2).reduce(0.0) do |distance, obj|
        distance + (obj[:distance] * obj[:weight])
      end
    end

    private

    def calculate_weighted_distances(i1, i2)
      distances = @rules.map do |attribute, rule|
        val1 = i1.send(attribute)
        val2 = i2.send(attribute)
        distance = rule[:calculator].calculate(val1, val2)
        next { distance: distance.to_f, weight: rule[:weight] } unless distance.nil?

        nil
      end
      normalize_weights_array(distances) if distances.compact!

      distances
    end

    def get_calculator(calculator)
      return calculator.new if calculator.is_a?(Class)

      klass_name = calculator.to_s.split('_').collect(&:capitalize).join.to_s
      klass = begin
        ::SlideRule::DistanceCalculators.const_get(klass_name)
      rescue::NameError
        nil
      end

      fail ArgumentError, "Unable to find calculator #{klass_name}" if klass.nil?

      klass.new
    end

    # Ensures all weights add up to 1.0
    #
    def normalize_weights(rules)
      weight_total = rules.map { |_attr, rule| rule[:weight] }.reduce(0.0, &:+)
      rules.each do |_attr, rule|
        rule[:weight] = rule[:weight] / weight_total
      end
    end

    # Ensures all weights add up to 1.0 in array of hashes
    #
    def normalize_weights_array(rules)
      weight_total = rules.map { |rule| rule[:weight] }.reduce(0.0, &:+)
      rules.each do |rule|
        rule[:weight] = rule[:weight] / weight_total
      end
    end

    # Prepares a duplicate of given rules hash with normalized weights and calculator instances
    #
    def prepare_rules(rules)
      prepared_rules = rules.each_with_object({}) do |(attribute, rule), copy|
        rule = copy[attribute] = safe_dup(rule)

        if rule[:type]
          puts 'Rule key `:type` is deprecated. Use `:calculator` instead.'
          rule[:calculator] = rule[:type]
        end

        rule[:calculator] = get_calculator(rule[:calculator])

        copy
      end
      prepared_rules = normalize_weights(prepared_rules)

      prepared_rules
    end

    def safe_dup(obj)
      obj.dup
    rescue
      obj
    end
  end
end
