require 'rails_helper'

RSpec.describe GemUsage, type: :model do
  context 'is valid' do
    it 'with valid attributes' do
      record = described_class.new resource: create(:resource), gem_version: create(:gem_version)
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
      record = described_class.new resource: create(:resource)
      expect(record).to_not be_a_valid_record
      expect(record.errors.full_messages).to eq ['Gem version must exist']
    end

    it 'without the in gemfile flag' do
      record = described_class.new resource: create(:resource), gem_version: create(:gem_version), in_gemfile: nil
      expect(record).to_not be_a_valid_record
      expect(record.errors.full_messages).to eq ['In gemfile can\'t be blank']
    end

    it 'if the same name is used twice' do
      resource = create :resource
      gem_version = create :gem_version
      described_class.create resource: resource, gem_version: gem_version
      record = described_class.new resource: resource, gem_version: gem_version
      expect(record).to_not be_a_valid_record
      expect(record.errors.full_messages).to eq ['Gem version has already been taken']
    end
  end

  describe '#gem_status' do
    subject { create :gem_usage }

    it 'current' do
      expect(subject.gem_status).to eq :current
      expect(subject.numeric_gem_status).to eq 2
    end

    it 'outdated' do
      create :gem_version, gem_info: subject.gem_info
      subject.reload
      expect(subject.gem_status).to eq :outdated
      expect(subject.numeric_gem_status).to eq 1
    end

    it 'vulnerable' do
      create :vulnerability, gem_version: subject.gem_version
      expect(subject.gem_status).to eq :vulnerable
      expect(subject.numeric_gem_status).to eq 0
    end
  end

  describe '#sort_by_gem_status' do
    before(:each) do
      @resource = create :empty_local_resource
      3.times do |i|
        # current
        create(:gem_info, name: "Current Gem #{i}") do |gem_info|
          @resource.gem_versions << create(:gem_version, gem_info: gem_info)
        end

        # outdated
        create(:gem_info, name: "Outdated Gem #{i}") do |gem_info|
          @resource.gem_versions << create(:gem_version, gem_info: gem_info)
          create :gem_version, gem_info: gem_info
        end

        # vulnerable
        create(:gem_info, name: "Vulnerable Gem #{i}") do |gem_info|
          @resource.gem_versions << create(:gem_version, gem_info: gem_info)
          create :vulnerability, gem_version: @resource.gem_versions.last
        end
      end
      @resource.reload
    end

    subject { @resource.gem_usages }

    it 'has a different default order' do
      expect(subject.map {|v| v.gem_info.name }).to eq [
        'Current Gem 0', 'Outdated Gem 0', 'Vulnerable Gem 0',
        'Current Gem 1', 'Outdated Gem 1', 'Vulnerable Gem 1',
        'Current Gem 2', 'Outdated Gem 2', 'Vulnerable Gem 2',
      ]
    end

    it 'sorts default ascending' do
      expect(subject.sort_by_gem_status.map {|v| v.gem_info.name }).to eq [
        'Vulnerable Gem 0', 'Vulnerable Gem 1', 'Vulnerable Gem 2',
        'Outdated Gem 0', 'Outdated Gem 1', 'Outdated Gem 2',
        'Current Gem 0', 'Current Gem 1', 'Current Gem 2',
      ]
    end

    it 'sorts ascending' do
      expect(subject.sort_by_gem_status(:asc).map {|v| v.gem_info.name }).to eq [
        'Vulnerable Gem 0', 'Vulnerable Gem 1', 'Vulnerable Gem 2',
        'Outdated Gem 0', 'Outdated Gem 1', 'Outdated Gem 2',
        'Current Gem 0', 'Current Gem 1', 'Current Gem 2',
      ]
    end

    it 'sorts descending' do
      expect(subject.sort_by_gem_status(:desc).map {|v| v.gem_info.name }).to eq [
        'Current Gem 0', 'Current Gem 1', 'Current Gem 2',
        'Outdated Gem 0', 'Outdated Gem 1', 'Outdated Gem 2',
        'Vulnerable Gem 0', 'Vulnerable Gem 1', 'Vulnerable Gem 2',
      ]
    end

    it 'raises an error with an invalid direction' do
      expect{subject.sort_by_gem_status(:invalid)}.to raise_error "Unknown direction :invalid. Available: :asc and :desc"
    end
  end
end
