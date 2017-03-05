require 'rails_helper'

RSpec.describe GemInfo, type: :model do
  context 'is valid'do
    it 'with valid attributes' do
      record = described_class.new name: 'Test Gem'
      expect(record).to be_a_valid_record
    end
  end

  context 'is not valid' do
    it 'without a name' do
      record = described_class.new
      expect(record).to_not be_a_valid_record
      expect(record.errors.full_messages).to eq ['Name can\'t be blank']
    end

    it 'if the same name is used twice' do
      described_class.create name: 'Test Gem'
      record = described_class.new name: 'Test Gem'
      expect(record).to_not be_a_valid_record
      expect(record.errors.full_messages).to eq ['Name has already been taken']
    end
  end

  it 'gets the newest gem version correctly' do
    gem_info = create :gem_info
    gem_info.gem_versions.create version: '4.3.2.beta'
    gem_info.gem_versions.create version: '1.2.3'
    gem_info.gem_versions.create version: '4.3.2'

    expect(gem_info.newest_gem_version.version).to eq '4.3.2'
  end
end
