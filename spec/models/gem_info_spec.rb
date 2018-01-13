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

  context 'updates all gem version if' do
    subject { create :gem_info }

    before do
      create :gem_version, gem_info: subject, version: '1.2.3'
      create :gem_version, gem_info: subject, version: '1.2.4'
      create :gem_version, gem_info: subject, version: '1.2.4.beta1'
      create :gem_version, gem_info: subject, version: '2.0.0.beta1'

      expect(subject.gem_versions.map {|v| [v.version, v.send(:outdated)] }).to eq [
        ['1.2.3', true],
        ['1.2.4', false],
        ['1.2.4.beta1', true],
        ['2.0.0.beta1', false],
      ]
    end

    it 'a newer version gets added' do
      create :gem_version, gem_info: subject, version: '2.0.0'

      expect(subject.gem_versions.map {|v| [v.version, v.send(:outdated)] }).to eq [
        ['1.2.3', true],
        ['1.2.4', true],
        ['1.2.4.beta1', true],
        ['2.0.0.beta1', true],
        ['2.0.0', false],
      ]
      expect(subject.newest_gem_version.version).to eq '2.0.0'
    end

    it 'an older version gets added' do
      create :gem_version, gem_info: subject, version: '1.2.1'

      expect(subject.gem_versions.map {|v| [v.version, v.send(:outdated)] }).to eq [
        ['1.2.3', true],
        ['1.2.4', false],
        ['1.2.4.beta1', true],
        ['2.0.0.beta1', false],
        ['1.2.1', true],
      ]
      expect(subject.newest_gem_version.version).to eq '1.2.4'
    end

    it 'a prerelease version gets added' do
      create :gem_version, gem_info: subject, version: '3.0.0.alpha'

      expect(subject.gem_versions.map {|v| [v.version, v.send(:outdated)] }).to eq [
        ['1.2.3', true],
        ['1.2.4', false],
        ['1.2.4.beta1', true],
        ['2.0.0.beta1', false],
        ['3.0.0.alpha', false],
      ]
      expect(subject.newest_gem_version.version).to eq '1.2.4'
    end

    it 'the newest version gets destroyed' do
      subject.gem_versions.where(version: '1.2.4').first!.destroy

      expect(subject.gem_versions.map {|v| [v.version, v.send(:outdated)] }).to eq [
        ['1.2.3', false],
        ['1.2.4.beta1', false],
        ['2.0.0.beta1', false],
      ]
      expect(subject.newest_gem_version.version).to eq '1.2.3'
    end

    it 'an older version gets destroyed' do
      subject.gem_versions.where(version: '1.2.3').first!.destroy

      expect(subject.gem_versions.map {|v| [v.version, v.send(:outdated)] }).to eq [
        ['1.2.4', false],
        ['1.2.4.beta1', true],
        ['2.0.0.beta1', false],
      ]
      expect(subject.newest_gem_version.version).to eq '1.2.4'
    end

    it 'a current prerelease version gets destroyed' do
      subject.gem_versions.where(version: '2.0.0.beta1').first!.destroy

      expect(subject.gem_versions.map {|v| [v.version, v.send(:outdated)] }).to eq [
        ['1.2.3', true],
        ['1.2.4', false],
        ['1.2.4.beta1', true],
      ]
      expect(subject.newest_gem_version.version).to eq '1.2.4'
    end

    it 'an outdated prerelease version gets destroyed' do
      subject.gem_versions.where(version: '1.2.4.beta1').first!.destroy

      expect(subject.gem_versions.map {|v| [v.version, v.send(:outdated)] }).to eq [
        ['1.2.3', true],
        ['1.2.4', false],
        ['2.0.0.beta1', false],
      ]
      expect(subject.newest_gem_version.version).to eq '1.2.4'
    end
  end
end
