require 'rails_helper'

RSpec.describe GemInfo, type: :model do
  context 'is valid'do
    it 'with valid attributes' do
      gem_info = GemInfo.new name: 'Test Gem', source: GemInfo::RUBYGEMS
      expect(gem_info.valid?).to be true
    end
  end

  context 'is not valid' do
    it 'without a name' do
      gem_info = GemInfo.new source: GemInfo::RUBYGEMS
      expect(gem_info.valid?).to be false
      expect(gem_info.errors.full_messages).to eq ['Name can\'t be blank']
    end

    it 'without a source' do
      gem_info = GemInfo.new name: 'Test Gem'
      expect(gem_info.valid?).to be false
      expect(gem_info.errors.full_messages).to eq ['Source can\'t be blank']
    end

    it 'if the same name is used twice' do
      GemInfo.create name: 'Test Gem', source: GemInfo::RUBYGEMS
      gem_info = GemInfo.new name: 'Test Gem', source: GemInfo::RUBYGEMS
      expect(gem_info.valid?).to be false
      expect(gem_info.errors.full_messages).to eq ['Name has already been taken']
    end
  end

  it 'finds the correct simliar gems' do
    g1 = GemInfo.create name: 'test-gem', source: GemInfo::RUBYGEMS
    g2 = GemInfo.create name: 'Test-Gem', source: GemInfo::RUBYGEMS
    g3 = GemInfo.create name: 'test-gem', source: 'https://mycode.test/repo'
    g4 = GemInfo.create name: 'another-test-gem', source: GemInfo::RUBYGEMS

    expect(g1.similar_gems.to_a).to eq [g2, g3]
    expect(g2.similar_gems.to_a).to eq [g1, g3]
    expect(g3.similar_gems.to_a).to eq [g1, g2]
    expect(g4.similar_gems.to_a).to eq []
  end
end
