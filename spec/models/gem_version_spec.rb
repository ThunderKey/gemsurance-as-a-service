require 'rails_helper'

RSpec.describe GemVersion, type: :model do
  describe 'is valid' do
    it 'with valid attributes' do
      record = described_class.new version: '1.2.3', gem_info: create(:gem_info)
      expect(record).to be_a_valid_record
    end
  end

  describe 'is not valid' do
    it 'without a version' do
      record = described_class.new gem_info: create(:gem_info)
      expect(record).to_not be_a_valid_record
      expect(record.errors.full_messages).to eq ['Version can\'t be blank']
    end

    it 'without a gem_info' do
      record = described_class.new version: '1.2.3'
      expect(record).to_not be_a_valid_record
      expect(record.errors.full_messages).to eq ['Gem info must exist']
    end

    it 'if the same version is used twice' do
      gem_info = create :gem_info
      described_class.create version: '1.2.3', gem_info: gem_info
      record = described_class.new version: '1.2.3', gem_info: gem_info
      expect(record).to_not be_a_valid_record
      expect(record.errors.full_messages).to eq ['Version has already been taken']
    end
  end

  describe 'sorting the versions' do
    before :each do
      gem_info = create :gem_info
      gem_info.gem_versions.create version: '1.2.3'
      gem_info.gem_versions.create version: '1.2.3.1'
      gem_info.gem_versions.create version: '1.2.3.1.beta'
      gem_info.gem_versions.create version: '10.0.0'
      gem_info.gem_versions.create version: '9.1.2'
    end

    it 'in ascending order' do
      expect(GemVersion.sort_by_version.map(&:version)).to eq [
        '1.2.3',
        '1.2.3.1.beta',
        '1.2.3.1',
        '9.1.2',
        '10.0.0',
      ]
    end

    it 'in descending order' do
      expect(GemVersion.sort_by_version(:desc).map(&:version)).to eq [
        '10.0.0',
        '9.1.2',
        '1.2.3.1',
        '1.2.3.1.beta',
        '1.2.3',
      ]
    end

    it 'gets the correct newest version' do
      expect(GemVersion.newest_version.version).to eq '10.0.0'
    end
  end
end
