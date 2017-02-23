require 'rails_helper'

RSpec.describe GemInfo, type: :model do
  it 'is valid with valid attributes' do
    gem_info = GemInfo.new name: 'Test Gem', source: GemInfo::RUBYGEMS
    expect(gem_info.valid?).to be true
  end

  it 'is not valid without a name' do
    gem_info = GemInfo.new source: GemInfo::RUBYGEMS
    expect(gem_info.valid?).to be false
    expect(gem_info.errors.full_messages).to eq ['Name can\'t be blank']
  end

  it 'is not valid without a source' do
    gem_info = GemInfo.new name: 'Test Gem'
    expect(gem_info.valid?).to be false
    expect(gem_info.errors.full_messages).to eq ['Source can\'t be blank']
  end

  it 'is not valid if the same name is used twice' do
    GemInfo.create name: 'Test Gem', source: GemInfo::RUBYGEMS
    gem_info = GemInfo.new name: 'Test Gem', source: GemInfo::RUBYGEMS
    expect(gem_info.valid?).to be false
    expect(gem_info.errors.full_messages).to eq ['Name has already been taken']
  end
end
