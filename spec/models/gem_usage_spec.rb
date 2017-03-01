require 'rails_helper'

RSpec.describe GemUsage, type: :model do
  context 'is valid' do
    it 'with valid attributes' do
      record = described_class.new resource: create(:local_resource), gem_version: create(:gem_version)
      expect(record).to be_a_valid_record
    end
  end

  context 'is not valid' do
    it 'without a resource' do
      record = described_class.new gem_version: create(:gem_version)
      expect(record).to_not be_a_valid_record
      expect(record.errors.full_messages).to eq ['Resource must exist']
    end

    it 'without a gem_version' do
      record = described_class.new resource: create(:local_resource)
      expect(record).to_not be_a_valid_record
      expect(record.errors.full_messages).to eq ['Gem version must exist']
    end

    it 'without the in gemfile flag' do
      record = described_class.new resource: create(:local_resource), gem_version: create(:gem_version), in_gemfile: nil
      expect(record).to_not be_a_valid_record
      expect(record.errors.full_messages).to eq ['In gemfile can\'t be blank']
    end

    it 'if the same name is used twice' do
      resource = create :local_resource
      gem_version = create :gem_version
      described_class.create resource: resource, gem_version: gem_version
      record = described_class.new resource: resource, gem_version: gem_version
      expect(record).to_not be_a_valid_record
      expect(record.errors.full_messages).to eq ['Gem version has already been taken']
    end
  end
end
