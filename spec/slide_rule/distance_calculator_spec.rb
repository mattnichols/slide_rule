require 'spec_helper'

describe ::SlideRule::DistanceCalculator do
  class ExampleTransaction
    attr_accessor :amount
    attr_accessor :description
    attr_accessor :date

    def initialize(attrs = {})
      @amount = attrs[:amount]
      @description = attrs[:description]
      @date = attrs[:date]
    end
  end

  class CustomCalc
    def calculate(_first, _second)
      0.9
    end
  end

  class NilCalc
    def calculate(_first, _second)
      nil
    end
  end

  let(:examples) do
    [
      ::ExampleTransaction.new(amount: 25.00,   date: '2015-02-05', description: 'Audible.com'),
      ::ExampleTransaction.new(amount: 34.89,   date: '2015-04-01', description: 'Questar Gas'),
      ::ExampleTransaction.new(amount: 1200.00, date: '2015-05-04', description: 'US Bank'),
      ::ExampleTransaction.new(amount: 560.00,  date: '2015-06-17', description: 'Wells Fargo Dealer Services'),
      ::ExampleTransaction.new(amount: 25.44,   date: '2015-06-03', description: 'Walmart'),
      ::ExampleTransaction.new(amount: 6.55,    date: '2015-06-01', description: 'Taco Bell'),
      ::ExampleTransaction.new(amount: 45.30,   date: '2015-06-26', description: 'Shell')
    ]
  end

  describe '#closest_match' do
    let(:calculator) do
      ::SlideRule::DistanceCalculator.new(
        description: {
          weight: 0.80,
          type: :levenshtein
        },
        date: {
          weight: 0.90,
          type: :day_of_month
        }
      )
    end

    it 'finds recurring transaction' do
      example = ExampleTransaction.new(description: 'Wells Fargo Dealer SVC', date: '2015-06-17')
      expect(calculator.closest_match(example, examples, 0.2)[:item]).to eq(examples[3])

      example = ExampleTransaction.new(description: 'Audible.com', date: '2015-06-05')
      expect(calculator.closest_match(example, examples, 0.2)[:item]).to eq(examples[0])
    end
  end

  describe '#calculate_distance' do
    context 'uses built-in calculator' do
      it 'should calculate perfect match' do
        calculator = ::SlideRule::DistanceCalculator.new(
          description: {
            weight: 1.00,
            type: :levenshtein
          },
          date: {
            weight: 0.50,
            type: :day_of_month
          }
        )
        example = ::ExampleTransaction.new(amount: 25.00, date: '2015-02-05', description: 'Audible.com')
        candidate = ::ExampleTransaction.new(amount: 25.00, date: '2015-06-05', description: 'Audible.com')
        expect(calculator.calculate_distance(example, candidate)).to eq(0.0)
      end

      it 'should calculate imperfect match' do
        calculator = ::SlideRule::DistanceCalculator.new(
          description: {
            weight: 0.50,
            type: :levenshtein
          },
          date: {
            weight: 0.50,
            type: :day_of_month
          }
        )
        example = ::ExampleTransaction.new(amount: 25.00, date: '2015-02-05', description: 'Audible.com')
        candidate = ::ExampleTransaction.new(amount: 25.00, date: '2015-06-08', description: 'Audible Inc')

        # <--------------------------------------->
        #  Distance Calculation:
        # <--------------------------------------->
        #   + Day of month distance = 3 * 0.5 / 15
        #   + Levenshtein distance = 4 * 0.5 / 11
        # -----------------------------------------
        #   = 0.2318181818181818
        distance = calculator.calculate_distance(example, candidate)
        expect(distance.round(4)).to eq(((3.0 * 0.5 / 15) + (4.0 * 0.5 / 11)).round(4))
      end

      it 'should renormalize on nil' do
        calculator = ::SlideRule::DistanceCalculator.new(
          description: {
            weight: 0.50,
            type: :levenshtein
          },
          date: {
            weight: 0.50,
            type: NilCalc
          }
        )
        example1 = ::ExampleTransaction.new(amount: 25.00, date: '2015-02-05', description: 'Audible.com')
        example2 = ::ExampleTransaction.new(amount: 25.00, date: '2015-06-08', description: 'Audible Inc')
        expect(calculator.calculate_distance(example1, example2).round(4)).to eq((4.0 / 11).round(4))
      end
    end

    context 'uses custom calculator' do
      it 'should load custom calculator' do
        calculator = ::SlideRule::DistanceCalculator.new(
          description: {
            weight: 1.00,
            type: CustomCalc
          }
        )
        example = ::ExampleTransaction.new
        candidate = ::ExampleTransaction.new

        distance = calculator.calculate_distance(example, candidate)
        expect(distance).to eq(0.9)
      end
    end
  end
end
