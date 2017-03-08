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

  it 'sees the correct versions as outdated' do
    gem_info_1 = create :gem_info
    gem_version_1_1 = gem_info_1.gem_versions.create version: '10.0.0'
    gem_version_1_2 = gem_info_1.gem_versions.create version: '9.1.2'
    gem_info_2 = create :gem_info
    gem_version_2_1 = gem_info_2.gem_versions.create version: '9.1.2'

    expect(gem_version_1_1.outdated?).to be false
    expect(gem_version_1_2.outdated?).to be true
    expect(gem_version_2_1.outdated?).to be false
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

  # TODO: Disabled until https://github.com/rails/rails/issues/28350 is fixed
  #describe '#gem_status' do
  #  it 'current' do
  #    record = create :gem_version
  #    expect(record.gem_status).to eq :current
  #    expect(record.numeric_gem_status).to eq 2
  #  end

  #  it 'outdated' do
  #    gem_info = create :gem_info
  #    record = create :gem_version, gem_info: gem_info
  #    create :gem_version, gem_info: gem_info
  #    expect(record.gem_status).to eq :outdated
  #    expect(record.numeric_gem_status).to eq 1
  #  end

  #  it 'vulnerable' do
  #    record = create :gem_version
  #    create :vulnerability, gem_version: record
  #    expect(record.gem_status).to eq :vulnerable
  #    expect(record.numeric_gem_status).to eq 0
  #  end
  #end

  #describe '#sort_by_gem_status' do
  #  before(:each) do
  #    @resource = create :empty_local_resource
  #    3.times do |i|
  #      # current
  #      create(:gem_info, name: "Current Gem #{i}") do |gem_info|
  #        @resource.gem_versions << create(:gem_version, gem_info: gem_info)
  #      end

  #      # outdated
  #      create(:gem_info, name: "Outdated Gem #{i}") do |gem_info|
  #        @resource.gem_versions << create(:gem_version, gem_info: gem_info)
  #        create :gem_version, gem_info: gem_info
  #      end

  #      # vulnerable
  #      create(:gem_info, name: "Vulnerable Gem #{i}") do |gem_info|
  #        @resource.gem_versions << create(:gem_version, gem_info: gem_info)
  #        create :vulnerability, gem_version: @resource.gem_versions.last
  #      end
  #    end
  #    @resource.reload
  #  end

  #  subject { @resource.gem_versions }

  #  it 'has a different default order' do
  #    expect(subject.map {|v| v.gem_info.name }).to eq [
  #      'Current Gem 0', 'Outdated Gem 0', 'Vulnerable Gem 0',
  #      'Current Gem 1', 'Outdated Gem 1', 'Vulnerable Gem 1',
  #      'Current Gem 2', 'Outdated Gem 2', 'Vulnerable Gem 2',
  #    ]
  #  end

  #  it 'sorts default ascending' do
  #    expect(subject.sort_by_gem_status.map {|v| v.gem_info.name }).to eq [
  #      'Vulnerable Gem 0', 'Vulnerable Gem 1', 'Vulnerable Gem 2',
  #      'Outdated Gem 0', 'Outdated Gem 1', 'Outdated Gem 2',
  #      'Current Gem 0', 'Current Gem 1', 'Current Gem 2',
  #    ]
  #  end

  #  it 'sorts ascending' do
  #    expect(subject.sort_by_gem_status(:asc).map {|v| v.gem_info.name }).to eq [
  #      'Vulnerable Gem 0', 'Vulnerable Gem 1', 'Vulnerable Gem 2',
  #      'Outdated Gem 0', 'Outdated Gem 1', 'Outdated Gem 2',
  #      'Current Gem 0', 'Current Gem 1', 'Current Gem 2',
  #    ]
  #  end

  #  it 'sorts descending' do
  #    expect(subject.sort_by_gem_status(:desc).map {|v| v.gem_info.name }).to eq [
  #      'Current Gem 0', 'Current Gem 1', 'Current Gem 2',
  #      'Outdated Gem 0', 'Outdated Gem 1', 'Outdated Gem 2',
  #      'Vulnerable Gem 0', 'Vulnerable Gem 1', 'Vulnerable Gem 2',
  #    ]
  #  end

  #  it 'raises an error with an invalid direction' do
  #    expect{subject.sort_by_gem_status(:invalid)}.to raise_error "Unknown direction :invalid. Available: :asc and :desc"
  #  end
  #end
end
