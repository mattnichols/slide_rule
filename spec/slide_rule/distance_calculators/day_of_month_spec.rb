require 'spec_helper'

describe ::SlideRule::DistanceCalculators::DayOfMonth do
  describe '#calculate' do
    it 'should give 0 on exact match' do
      expect(described_class.new.calculate('2012-03-19', '2014-08-19')).to eq(0.0)
    end

    it 'should accept epoch date' do
      expect(described_class.new.calculate(1_444_262_400, 1_444_262_400)).to eq(0.0)
    end

    it 'should calculate when date is in the same month' do
      expect(described_class.new.calculate('2012-03-19', '2014-08-22')).to eq(3.0 / 15)
      expect(described_class.new.calculate('2012-03-19', '2014-08-09')).to eq(10.0 / 15)
    end

    it 'should calculate when date wraps to next month, using 15 as max number of days' do
      expect(described_class.new.calculate('2012-03-30', '2014-04-02')).to eq(2.0 / 15)
    end
  end

  describe '#difference_in_days' do
    describe 'calculates using 15 day max' do
      [
        ['same day',       Date.parse('2012-03-30'), Date.parse('2014-04-30'),  0],
        ['one day after',  Date.parse('2012-03-19'), Date.parse('2014-04-20'),  1],
        ['one day before', Date.parse('2012-03-18'), Date.parse('2014-04-19'),  1],

        ['14 days before', Date.parse('2012-03-15'), Date.parse('2014-04-01'), 14],
        ['14 days after',  Date.parse('2012-03-15'), Date.parse('2014-04-01'), 14],

        ['15 days before', Date.parse('2012-03-16'), Date.parse('2014-04-01'), 15],
        ['15 days after',  Date.parse('2012-03-01'), Date.parse('2014-04-16'), 15],

        ['16 days before', Date.parse('2012-03-17'), Date.parse('2014-04-01'), 14],
        ['16 days after',  Date.parse('2012-03-01'), Date.parse('2014-04-17'), 14],

        ['last day of month and first of next month (30 day month)',  Date.parse('2012-04-30'), Date.parse('2014-05-01'), 1],

        ## Not sure how to account for these
        ['last day of month and first of next month (leap year)',     Date.parse('2012-02-29'), Date.parse('2014-04-01'), 2], # should be 1 day?
        ['last day of month and first of next month (31 day month)',  Date.parse('2012-03-31'), Date.parse('2014-04-01'), 0], # should be 1 day?
        ['last day of month and first of next month (28 day month)',  Date.parse('2012-02-28'), Date.parse('2014-04-01'), 3], # should be 1 day?
      ].each do |example|
        it "when dates are #{example[0]}" do
          expect(described_class.new.difference_in_days(example[1], example[2])).to eq(example[3])
        end
      end
    end
  end
end
