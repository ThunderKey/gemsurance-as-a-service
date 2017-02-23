require 'rails_helper'

RSpec.describe GemVersion, type: :model do
  it 'is valid with valid attributes' do
    gem_version = GemVersion.new version: '1.2.3', gem_info: create(:gem_info)
    expect(gem_version.valid?).to be true
  end

  it 'is not valid without a version' do
    gem_version = GemVersion.new gem_info: create(:gem_info)
    expect(gem_version.valid?).to be false
    expect(gem_version.errors.full_messages).to eq ['Version can\'t be blank']
  end

  it 'is not valid without a gem_info' do
    gem_version = GemVersion.new version: '1.2.3'
    expect(gem_version.valid?).to be false
    expect(gem_version.errors.full_messages).to eq ['Gem info must exist']
  end

  it 'is not valid if the same version is used twice' do
    gem_info = create :gem_info
    GemVersion.create version: '1.2.3', gem_info: gem_info
    gem_version = GemVersion.new version: '1.2.3', gem_info: gem_info
    expect(gem_version.valid?).to be false
    expect(gem_version.errors.full_messages).to eq ['Version has already been taken']
  end
end
