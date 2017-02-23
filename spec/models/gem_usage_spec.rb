require 'rails_helper'

RSpec.describe GemUsage, type: :model do
  it 'is valid with valid attributes' do
    gem_usage = GemUsage.new resource: create(:local_resource), gem_version: create(:gem_version)
    expect(gem_usage.valid?).to be true
  end

  it 'is not valid without a resource' do
    gem_usage = GemUsage.new gem_version: create(:gem_version)
    expect(gem_usage.valid?).to be false
    expect(gem_usage.errors.full_messages).to eq ['Resource must exist']
  end

  it 'is not valid without a gem_version' do
    gem_usage = GemUsage.new resource: create(:local_resource)
    expect(gem_usage.valid?).to be false
    expect(gem_usage.errors.full_messages).to eq ['Gem version must exist']
  end

  it 'is not valid if the same name is used twice' do
    resource = create :local_resource
    gem_version = create :gem_version
    GemUsage.create resource: resource, gem_version: gem_version
    gem_usage = GemUsage.new resource: resource, gem_version: gem_version
    expect(gem_usage.valid?).to be false
    expect(gem_usage.errors.full_messages).to eq ['Gem version has already been taken']
  end
end
