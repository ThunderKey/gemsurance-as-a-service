require 'rails_helper'

RSpec.describe GemUsage, type: :model do
  it 'is valid with valid attributes' do
    record = described_class.new resource: create(:local_resource), gem_version: create(:gem_version)
    expect(record.valid?).to be true
  end

  it 'is not valid without a resource' do
    record = described_class.new gem_version: create(:gem_version)
    expect(record.valid?).to be false
    expect(record.errors.full_messages).to eq ['Resource must exist']
  end

  it 'is not valid without a gem_version' do
    record = described_class.new resource: create(:local_resource)
    expect(record.valid?).to be false
    expect(record.errors.full_messages).to eq ['Gem version must exist']
  end

  it 'is not valid if the same name is used twice' do
    resource = create :local_resource
    gem_version = create :gem_version
    described_class.create resource: resource, gem_version: gem_version
    record = described_class.new resource: resource, gem_version: gem_version
    expect(record.valid?).to be false
    expect(record.errors.full_messages).to eq ['Gem version has already been taken']
  end
end
