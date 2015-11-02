[![Gem Version](https://badge.fury.io/rb/slide_rule.svg)](https://badge.fury.io/rb/slide_rule)

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

##Describe the field calculators

Each field to be considered in the distance calculation should be described 
with a calculation method and weight(optional)

Valid calculators:

* day_of_month (this needs to be factored into configurable date_recurrence)
* float_range_distance

```ruby
distance_rules = {
  :description => {
    :weight => 0.80,
    :type => :levenshtein,
  },
  :date => {
    :weight => 0.90,
    :type => :day_of_month,
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
