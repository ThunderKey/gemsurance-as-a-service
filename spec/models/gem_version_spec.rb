require 'rails_helper'

RSpec.describe GemVersion, type: :model do
  it 'is valid with valid attributes' do
    record = described_class.new version: '1.2.3', gem_info: create(:gem_info)
    expect(record).to be_a_valid_record
  end

  it 'is not valid without a version' do
    record = described_class.new gem_info: create(:gem_info)
    expect(record).to_not be_a_valid_record
    expect(record.errors.full_messages).to eq ['Version can\'t be blank']
  end

  it 'is not valid without a gem_info' do
    record = described_class.new version: '1.2.3'
    expect(record).to_not be_a_valid_record
    expect(record.errors.full_messages).to eq ['Gem info must exist']
  end

  it 'is not valid if the same version is used twice' do
    gem_info = create :gem_info
    described_class.create version: '1.2.3', gem_info: gem_info
    record = described_class.new version: '1.2.3', gem_info: gem_info
    expect(record).to_not be_a_valid_record
    expect(record.errors.full_messages).to eq ['Version has already been taken']
  end
end
