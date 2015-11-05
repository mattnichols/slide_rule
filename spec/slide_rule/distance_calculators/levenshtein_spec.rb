require 'spec_helper'

describe ::SlideRule::DistanceCalculators::Levenshtein do
  it 'should calculate perfect match' do
    expect(described_class.new.calculate('this is a test', 'this is a test')).to eq(0.0)
  end

  it 'should calculate distance as distance divided by length of longest string' do
    expect(described_class.new.calculate('this is a test', 'this is a test!').round(4)).to eq((1.0 / 15).round(4))
  end
end
