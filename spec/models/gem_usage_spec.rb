# frozen_string_literal: true

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
      expect(record).not_to be_a_valid_record
      expect(record.errors.full_messages).to eq ['Resource must exist']
    end

    it 'without a gem_version' do
      record = described_class.new resource: create(:resource)
      expect(record).not_to be_a_valid_record
      expect(record.errors.full_messages).to eq ['Gem version must exist']
    end

    it 'without the in gemfile flag' do
      record = described_class.new(
        resource: create(:resource),
        gem_version: create(:gem_version),
        in_gemfile: nil,
      )
      expect(record).not_to be_a_valid_record
      expect(record.errors.full_messages).to eq ['In gemfile can\'t be blank']
    end

    it 'if the same name is used twice' do
      resource = create :resource
      gem_version = create :gem_version
      described_class.create resource: resource, gem_version: gem_version
      record = described_class.new resource: resource, gem_version: gem_version
      expect(record).not_to be_a_valid_record
      expect(record.errors.full_messages).to eq ['Gem version has already been taken']
    end
  end

  describe '#gem_status' do
    subject(:gem_usage) { create :gem_usage }

    it 'current' do
      expect(gem_usage.gem_status).to eq :current
      expect(gem_usage.numeric_gem_status).to eq 2
    end

    it 'outdated' do
      create :gem_version, gem_info: gem_usage.gem_info
      gem_usage.reload
      expect(gem_usage.gem_status).to eq :outdated
      expect(gem_usage.numeric_gem_status).to eq 1
    end

    it 'vulnerable' do
      create :vulnerability, gem_version: gem_usage.gem_version
      expect(gem_usage.gem_status).to eq :vulnerable
      expect(gem_usage.numeric_gem_status).to eq 0
    end

    it 'unknown' do
      # 2 times because checking the value and again in the raise statement
      expect(gem_usage).to receive(:gem_status).twice.and_return :unknown
      expect {gem_usage.numeric_gem_status}
        .to raise_error 'Unsupported gem_status :unknown'
    end
  end

  describe '#sort_by_gem_status' do
    subject(:gem_usages) { resource.gem_usages }

    let(:resource) { create :empty_local_resource }

    before do
      3.times do |i|
        # current
        create(:gem_info, name: "Current Gem #{i}") do |gem_info|
          resource.gem_versions << create(:gem_version, gem_info: gem_info)
        end

        # outdated
        create(:gem_info, name: "Outdated Gem #{i}") do |gem_info|
          resource.gem_versions << create(:gem_version, gem_info: gem_info)
          create :gem_version, gem_info: gem_info
        end

        # vulnerable
        create(:gem_info, name: "Vulnerable Gem #{i}") do |gem_info|
          resource.gem_versions << create(:gem_version, gem_info: gem_info)
          create :vulnerability, gem_version: resource.gem_versions.last
        end
      end
      resource.reload
    end

    it 'has a different default order' do
      expect(gem_usages.map {|v| v.gem_info.name }).to eq [
        'Current Gem 0', 'Outdated Gem 0', 'Vulnerable Gem 0',
        'Current Gem 1', 'Outdated Gem 1', 'Vulnerable Gem 1',
        'Current Gem 2', 'Outdated Gem 2', 'Vulnerable Gem 2'
      ]
    end

    it 'sorts default ascending' do
      expect(gem_usages.sort_by_gem_status.map {|v| v.gem_info.name }).to eq [
        'Vulnerable Gem 0', 'Vulnerable Gem 1', 'Vulnerable Gem 2',
        'Outdated Gem 0', 'Outdated Gem 1', 'Outdated Gem 2',
        'Current Gem 0', 'Current Gem 1', 'Current Gem 2'
      ]
    end

    it 'sorts ascending' do
      expect(gem_usages.sort_by_gem_status(:asc).map {|v| v.gem_info.name }).to eq [
        'Vulnerable Gem 0', 'Vulnerable Gem 1', 'Vulnerable Gem 2',
        'Outdated Gem 0', 'Outdated Gem 1', 'Outdated Gem 2',
        'Current Gem 0', 'Current Gem 1', 'Current Gem 2'
      ]
    end

    it 'sorts descending' do
      expect(gem_usages.sort_by_gem_status(:desc).map {|v| v.gem_info.name }).to eq [
        'Current Gem 0', 'Current Gem 1', 'Current Gem 2',
        'Outdated Gem 0', 'Outdated Gem 1', 'Outdated Gem 2',
        'Vulnerable Gem 0', 'Vulnerable Gem 1', 'Vulnerable Gem 2'
      ]
    end

    it 'raises an error with an invalid direction' do
      expect {gem_usages.sort_by_gem_status(:invalid)}
        .to raise_error 'Unknown direction :invalid. Available: :asc and :desc'
    end
  end

  describe 'on destroy' do
    subject!(:gem_usage) { create :gem_usage, gem_version: gem_version }

    let(:gem_info) { create :gem_info }
    let(:gem_version) { create :gem_version, gem_info: gem_info }

    it 'deletes its gem version if there are no other usages' do
      create :gem_version, gem_info: gem_info
      expect do
        gem_usage.destroy
      end.to(change { GemVersion.exists? gem_version.id }.from(true).to(false))
    end

    it 'keeps its gem version if there are no other usages' do
      create :gem_version, gem_info: gem_info
      create :gem_usage, gem_version: gem_version
      expect do
        gem_usage.destroy
      end.not_to(change { GemVersion.exists? gem_version.id })
    end

    it 'keeps its gem version if its the newest version' do
      create :gem_usage, gem_version: gem_version
      expect do
        gem_usage.destroy
      end.not_to(change { GemVersion.exists? gem_version.id })
    end
  end
end
