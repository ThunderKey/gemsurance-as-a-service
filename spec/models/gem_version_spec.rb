# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GemVersion, type: :model do
  describe 'is valid' do
    it 'with valid attributes' do
      record = described_class.new version: '1.2.3', gem_info: create(:gem_info)
      expect(record).to be_a_valid_record
    end
  end

  describe 'outdated' do
    subject(:gem_version) { create :gem_version }

    it 'prevents the access to the db getter' do
      expect { gem_version.outdated }
        .to raise_error /\Aprivate method `outdated' called for #{gem_version}/
    end

    it 'would return the correct value if accessed with send' do
      expect(gem_version.outdated?).to eq false
      expect(gem_version.send(:outdated)).to eq false

      gem_version.outdated = true
      expect(gem_version.outdated?).to eq true
      expect(gem_version.send(:outdated)).to eq true

      gem_version.outdated = nil
      expect { gem_version.outdated? }
        .to raise_error 'the GemInfo#update_new_gem_versions! did not get called!'
      expect(gem_version.send(:outdated)).to eq nil
    end
  end

  describe 'is not valid' do
    it 'without a version' do
      record = described_class.new gem_info: create(:gem_info)
      expect(record).not_to be_a_valid_record
      expect(record.errors.full_messages).to eq ['Version can\'t be blank']
    end

    it 'without a gem_info' do
      record = described_class.new version: '1.2.3'
      expect(record).not_to be_a_valid_record
      expect(record.errors.full_messages).to eq ['Gem info must exist']
    end

    it 'if the same version is used twice' do
      gem_info = create :gem_info
      described_class.create version: '1.2.3', gem_info: gem_info
      record = described_class.new version: '1.2.3', gem_info: gem_info
      expect(record).not_to be_a_valid_record
      expect(record.errors.full_messages).to eq ['Version has already been taken']
    end
  end

  it 'sees the correct versions as outdated' do
    gem_info1 = create :gem_info
    gem_version11 = gem_info1.gem_versions.create version: '10.0.0'
    gem_version12 = gem_info1.gem_versions.create version: '9.1.2'
    gem_info2 = create :gem_info
    gem_version21 = gem_info2.gem_versions.create version: '9.1.2'

    expect(gem_version11.outdated?).to be false
    expect(gem_version12.outdated?).to be true
    expect(gem_version21.outdated?).to be false
  end

  describe 'sorting the versions' do
    before do
      gem_info = create :gem_info
      gem_info.gem_versions.create version: '1.2.3'
      gem_info.gem_versions.create version: '1.2.3.1'
      gem_info.gem_versions.create version: '1.2.3.1.beta'
      gem_info.gem_versions.create version: '10.0.0'
      gem_info.gem_versions.create version: '9.1.2'
    end

    it 'in ascending order' do
      expect(described_class.all.sort_by(&:version_object).map(&:version)).to eq [
        '1.2.3',
        '1.2.3.1.beta',
        '1.2.3.1',
        '9.1.2',
        '10.0.0',
      ]
    end

    it 'in descending order' do
      expect(described_class.all.sort_by(&:version_object).reverse.map(&:version)).to eq [
        '10.0.0',
        '9.1.2',
        '1.2.3.1',
        '1.2.3.1.beta',
        '1.2.3',
      ]
    end
  end

  describe '#gem_status' do
    it 'current' do
      record = create :gem_version
      expect(record.gem_status).to eq :current
      expect(record.numeric_gem_status).to eq 2
    end

    it 'current but with a prerelease' do
      gem_info = create :gem_info
      create :gem_version, version: '1.2.3.pre1', gem_info: gem_info
      record = create :gem_version, version: '1.2.3', gem_info: gem_info
      expect(record.gem_status).to eq :current
      expect(record.numeric_gem_status).to eq 2
    end

    it 'current with only prereleases' do
      gem_info = create :gem_info
      create :gem_version, version: '1.2.3.pre2', gem_info: gem_info
      record = create :gem_version, version: '1.2.3.pre1', gem_info: gem_info
      expect(record.gem_status).to eq :current
      expect(record.numeric_gem_status).to eq 2
    end

    it 'outdated' do
      gem_info = create :gem_info
      record = create :gem_version, gem_info: gem_info
      create :gem_version, gem_info: gem_info
      record.reload
      expect(record.gem_status).to eq :outdated
      expect(record.numeric_gem_status).to eq 1
    end

    it 'outdated as a prerelease' do
      gem_info = create :gem_info
      create :gem_version, version: '1.2.4', gem_info: gem_info
      record = create :gem_version, version: '1.2.3.pre1', gem_info: gem_info
      expect(record.gem_status).to eq :outdated
      expect(record.numeric_gem_status).to eq 1
    end

    it 'vulnerable' do
      record = create :gem_version
      create :vulnerability, gem_version: record
      expect(record.gem_status).to eq :vulnerable
      expect(record.numeric_gem_status).to eq 0
    end

    it 'unknown' do
      record = create :gem_version
      # 2 times because checking the value and again in the raise statement
      expect(record).to receive(:gem_status).twice.and_return :unknown
      expect {record.numeric_gem_status}
        .to raise_error 'Unsupported gem_status :unknown'
    end
  end

  describe '#sort_by_gem_status' do
    subject(:gem_versions) { resource.gem_versions }

    let(:resource) do
      create :empty_local_resource do |r|
        3.times do |i|
          # current
          create(:gem_info, name: "Current Gem #{i}") do |gem_info|
            r.gem_versions << create(:gem_version, gem_info: gem_info)
          end

          # outdated
          create(:gem_info, name: "Outdated Gem #{i}") do |gem_info|
            r.gem_versions << create(:gem_version, gem_info: gem_info)
            create :gem_version, gem_info: gem_info
          end

          # vulnerable
          create(:gem_info, name: "Vulnerable Gem #{i}") do |gem_info|
            r.gem_versions << create(:gem_version, gem_info: gem_info)
            create :vulnerability, gem_version: r.gem_versions.last
          end
        end
        r.reload
      end
    end

    it 'has a different default order' do
      expect(gem_versions.map {|v| v.gem_info.name }).to eq [
        'Current Gem 0', 'Outdated Gem 0', 'Vulnerable Gem 0',
        'Current Gem 1', 'Outdated Gem 1', 'Vulnerable Gem 1',
        'Current Gem 2', 'Outdated Gem 2', 'Vulnerable Gem 2'
      ]
    end

    it 'sorts default ascending' do
      expect(gem_versions.sort_by_gem_status.map {|v| v.gem_info.name }).to eq [
        'Vulnerable Gem 0', 'Vulnerable Gem 1', 'Vulnerable Gem 2',
        'Outdated Gem 0', 'Outdated Gem 1', 'Outdated Gem 2',
        'Current Gem 0', 'Current Gem 1', 'Current Gem 2'
      ]
    end

    it 'sorts ascending' do
      expect(gem_versions.sort_by_gem_status(:asc).map {|v| v.gem_info.name }).to eq [
        'Vulnerable Gem 0', 'Vulnerable Gem 1', 'Vulnerable Gem 2',
        'Outdated Gem 0', 'Outdated Gem 1', 'Outdated Gem 2',
        'Current Gem 0', 'Current Gem 1', 'Current Gem 2'
      ]
    end

    it 'sorts descending' do
      expect(gem_versions.sort_by_gem_status(:desc).map {|v| v.gem_info.name }).to eq [
        'Current Gem 0', 'Current Gem 1', 'Current Gem 2',
        'Outdated Gem 0', 'Outdated Gem 1', 'Outdated Gem 2',
        'Vulnerable Gem 0', 'Vulnerable Gem 1', 'Vulnerable Gem 2'
      ]
    end

    it 'raises an error with an invalid direction' do
      expect {gem_versions.sort_by_gem_status(:invalid)}
        .to raise_error 'Unknown direction :invalid. Available: :asc and :desc'
    end
  end
end
