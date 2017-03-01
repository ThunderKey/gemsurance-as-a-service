require 'rails_helper'

RSpec.describe Resource, type: :model do
  valid_path = File.join Rails.root, 'spec', 'assets', 'valid_app'
  missing_path = File.join Rails.application.config.test_tmp_dir, 'missing_app'

  context 'is valid' do
    it 'with all required attributes' do
      record = described_class.new name: 'Test described_class', resource_type: 'local', path: valid_path
      expect(record).to be_a_valid_record
    end

    it 'with all required and optional attributes' do
      record = described_class.new name: 'Test described_class', resource_type: 'local', path: valid_path, build_url: 'https://test.test/mytest', build_image_url: 'https://test.test/mytest.png'
      expect(record).to be_a_valid_record
    end
  end

  context 'is not valid' do
    it 'without a name' do
      record = described_class.new resource_type: 'local', path: valid_path
      expect(record).to_not be_a_valid_record
      expect(record.errors.full_messages).to eq ['Name can\'t be blank']
    end

    it 'without a resource_type' do
      record = described_class.new name: 'Test described_class', path: valid_path
      expect(record).to_not be_a_valid_record
      expect(record.errors.full_messages).to eq ['Resource type can\'t be blank']
    end

    it 'without a path' do
      record = described_class.new name: 'Test described_class', resource_type: 'local'
      expect(record).to_not be_a_valid_record
      expect(record.errors.full_messages).to eq ['Path can\'t be blank', 'Path must be an absolute path']
    end

    it 'with an non-existing path' do
      record = described_class.new name: 'Test described_class', resource_type: 'local', path: missing_path
      expect(record).to_not be_a_valid_record
      expect(record.errors.full_messages).to eq ['Path does not exist']
    end

    it 'with an empty path' do
      FileUtils.mkdir_p missing_path
      record = described_class.new name: 'Test described_class', resource_type: 'local', path: missing_path
      expect(record).to_not be_a_valid_record
      expect(record.errors.full_messages).to eq ['Path does not contain Gemfile', 'Path does not contain Gemfile.lock']
    end

    it 'if the same name is used twice' do
      described_class.create name: 'Test described_class', resource_type: 'local', path: valid_path
      record = described_class.new name: 'Test described_class', resource_type: 'local', path: valid_path
      expect(record).to_not be_a_valid_record
      expect(record.errors.full_messages).to eq ['Name has already been taken']
    end

    it 'if the build_url is not a url' do
      record = described_class.new name: 'Test described_class', resource_type: 'local', path: valid_path, build_url: 'test.ch/asdf'
      expect(record).to_not be_a_valid_record
      expect(record.errors.full_messages).to eq ['Build url must be a valid URL']
    end

    it 'if the build_image_url is not a url' do
      record = described_class.new name: 'Test described_class', resource_type: 'local', path: valid_path, build_image_url: 'test.ch/asdf'
      expect(record).to_not be_a_valid_record
      expect(record.errors.full_messages).to eq ['Build image url must be a valid URL']
    end
  end

  it 'updates the gems correctly' do
    record = create :local_resource
    create :gem_usage, resource: record
    expect(gem_usages_to_arrays record.gem_usages).to eq [
      ["TestGem#1", "1.2.3", "https://rubygems.org/", false],
    ]
    expect(record.gem_usages.size).to be 1
    expect(record.gem_versions.size).to be 1
    expect(record.gem_infos.size).to be 1

    record.update_gems!

    expect(gem_usages_to_arrays record.gem_usages).to eq [
      ["rake", "12.0.0", "https://rubygems.org/", false],
      ["concurrent-ruby", "1.0.4", "https://rubygems.org/", false],
      ["i18n", "0.8.0", "https://rubygems.org/", false],
      ["minitest", "5.10.1", "https://rubygems.org/", false],
      ["thread_safe", "0.3.5", "https://rubygems.org/", false],
      ["tzinfo", "1.2.2", "https://rubygems.org/", false],
      ["activesupport", "5.0.1", "https://rubygems.org/", false],
      ["builder", "3.2.3", "https://rubygems.org/", false],
      ["erubis", "2.7.0", "https://rubygems.org/", false],
      ["mini_portile2", "2.1.0", "https://rubygems.org/", false],
      ["nokogiri", "1.7.0.1", "https://rubygems.org/", false],
      ["rails-dom-testing", "2.0.2", "https://rubygems.org/", false],
      ["loofah", "2.0.3", "https://rubygems.org/", false],
      ["rails-html-sanitizer", "1.0.3", "https://rubygems.org/", false],
      ["actionview", "5.0.1", "https://rubygems.org/", false],
      ["rack", "2.0.1", "https://rubygems.org/", false],
      ["rack-test", "0.6.3", "https://rubygems.org/", false],
      ["actionpack", "5.0.1", "https://rubygems.org/", false],
      ["bcrypt", "3.1.11", "https://rubygems.org/", false],
      ["orm_adapter", "0.5.0", "https://rubygems.org/", false],
      ["method_source", "0.8.2", "https://rubygems.org/", false],
      ["thor", "0.19.4", "https://rubygems.org/", false],
      ["railties", "5.0.1", "https://rubygems.org/", false],
      ["responders", "2.3.0", "https://rubygems.org/", false],
      ["warden", "1.2.7", "https://rubygems.org/", false],
      ["devise", "4.2.0", "https://rubygems.org/", true],
      ["multipart-post", "2.0.0", "https://rubygems.org/", false],
      ["faraday", "0.10.1", "https://rubygems.org/", false],
      ["hashie", "3.5.3", "https://rubygems.org/", false],
      ["jwt", "1.5.6", "https://rubygems.org/", false],
      ["multi_json", "1.12.1", "https://rubygems.org/", false],
      ["multi_xml", "0.6.0", "https://rubygems.org/", false],
      ["oauth2", "1.3.0", "https://rubygems.org/", false],
      ["omniauth", "1.6.1", "https://rubygems.org/", false],
      ["omniauth-oauth2", "1.3.1", "https://rubygems.org/", false],
      ["omniauth-keltec", "0.0.1", "https://github.com/ThunderKey/omniauth-keltec.git", true]
    ]
    expect(record.gem_usages.size).to be 36
    expect(record.gem_versions.size).to be 36
    expect(record.gem_infos.size).to be 36
  end

  it 'generates the correct resource_type data' do
    expect(described_class.resource_types).to eq('local' => 'local')

    described_class.resource_types.each do |type, value|
      expect(ResourceFetcher[type]).to_not be nil
      expect(ResourceFetcher[type].ancestors).to include ResourceFetcher::Base
    end
    expect(described_class.resource_type_attributes_for_select).to eq [
      ['Local', 'local'],
    ]
  end

  def gem_usages_to_arrays usages
    usages.map {|gu| [gu.gem_info.name, gu.gem_version.version, gu.gem_info.source, gu.in_gemfile] }
  end
end
