require 'rails_helper'

RSpec.describe GemInfo, type: :model do
  context 'is valid'do
    it 'with valid attributes' do
      record = described_class.new name: 'Test Gem', source: described_class::RUBYGEMS
      expect(record.valid?).to be true
    end
  end

  context 'is not valid' do
    it 'without a name' do
      record = described_class.new source: described_class::RUBYGEMS
      expect(record.valid?).to be false
      expect(record.errors.full_messages).to eq ['Name can\'t be blank']
    end

    it 'without a source' do
      record = described_class.new name: 'Test Gem'
      expect(record.valid?).to be false
      expect(record.errors.full_messages).to eq ['Source can\'t be blank']
    end

    it 'if the same name is used twice' do
      described_class.create name: 'Test Gem', source: described_class::RUBYGEMS
      record = described_class.new name: 'Test Gem', source: described_class::RUBYGEMS
      expect(record.valid?).to be false
      expect(record.errors.full_messages).to eq ['Name has already been taken']
    end
  end

  it 'finds the correct simliar gems' do
    r1 = described_class.create name: 'test-gem', source: described_class::RUBYGEMS
    r2 = described_class.create name: 'Test-Gem', source: described_class::RUBYGEMS
    r3 = described_class.create name: 'test-gem', source: 'https://mycode.test/repo'
    r4 = described_class.create name: 'another-test-gem', source: described_class::RUBYGEMS

    expect(r1.similar_gems.to_a).to eq [r2, r3]
    expect(r2.similar_gems.to_a).to eq [r1, r3]
    expect(r3.similar_gems.to_a).to eq [r1, r2]
    expect(r4.similar_gems.to_a).to eq []
  end
end
