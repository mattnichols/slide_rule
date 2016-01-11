[![Gem Version](https://badge.fury.io/rb/slide_rule.svg)](https://badge.fury.io/rb/slide_rule) [![Build Status](https://travis-ci.org/mattnichols/slide_rule.svg)](https://travis-ci.org/mattnichols/slide_rule)

# SlideRule
Ruby object distance calculator

##Distance

The distance between 2 objects is calculated as a float between 0.0 (perfect match) and 1.0 (farthest distance).

All calculators result in a distance between 0.0 and 1.0.

    Total distance = sum of all weighted distances.

Weights are normalized as follows:

    weight = weight * (% of sum of all weights)

_Note: weights are assumed to be equal if not provided_

#API

##Describe the field distance calculators

Each field to be considered in the distance calculation should be described 
with a calculation method and weight(optional)

Valid calculators:

* day_of_year
* day_of_month
* levenshtein

```ruby
distance_rules = {
  :description => {
    :weight => 0.80,
    :calculator => :levenshtein,
  },
  :date => {
    :weight => 0.90,
    :calculator => :day_of_month,
  },
}
```

## Build the object distance calculator

```ruby
matcher = ::SlideRule::DistanceCalculator.new(distance_rules)
```

## Use the calculator

```ruby
# Example data
example = ::ExampleTransaction.new(
  :amount => 25.00,
  :date => '2015-02-05',
  :description => 'Audible.com'
)
example2 = ::ExampleTransaction.new(
  :amount => 250.00,
  :date => '2015-02-16',
  :description => 'Wells Fargo Dealer Services'
)
candidate = ::ExampleTransaction.new(
  :amount => 25.00,
  :date => '2015-06-08',
  :description => 'Audible Inc'
)

# Calculate distance
matcher.calculate_distance(example, candidate)
=> 0.2318181818181818

# Find closest match to examples in an array
matcher.closest_match(candidate, [example, example2])
=> example

# Find closest match to examples in an array, using a threshold
matcher.closest_match(candidate, [example, example2], 0.2)
=> example

```

## Custom Field Distance Calculators

To define a custom field distance calculator, define a class with a `calculate(value1, value2)` method.

Requirements:
* Class must be stateless
* Calculate should return a float from `0` (perfect match) to `1.0` (no match)
* Calculation should not be order dependent (e.g. `calculate(a, b) == calculate(b, a)`)

```ruby
class StringLengthCalculator
  def calculate(l1, l2)
    diff = (l1 - l2).abs.to_f
    return diff / [l1, l2].max
  end
end

matcher = ::SlideRule::DistanceCalculator.new(
  :length => {
    :weight => 1.0,
    :calculator => StringLengthCalculator
  }
)

# Find the string with the closest length
matcher.closest_match("Howdy Doody Time!", ["Felix the cat", "Mighty Mouse"], 0.5)
# => { :item=>"Mighty Mouse", :distance=>0.29411764705882354 }
```

See the [distance_calculators](https://github.com/mattnichols/slide_rule/tree/master/lib/slide_rule/distance_calculators) directory in source for more examples.


# To Do

* Add more field distance calculators


