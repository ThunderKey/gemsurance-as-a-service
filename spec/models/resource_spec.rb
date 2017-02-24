require 'rails_helper'

RSpec.describe Resource, type: :model do
  valid_path = File.join Rails.root, 'spec', 'assets', 'valid_app'
  missing_path = File.join Rails.application.config.test_tmp_dir, 'missing_app'

  context 'is valid' do
    it 'with all required attributes' do
      record = described_class.new name: 'Test described_class', resource_type: 'local', path: valid_path
      expect(record.valid?).to be true
    end

    it 'with all required and optional attributes' do
      record = described_class.new name: 'Test described_class', resource_type: 'local', path: valid_path, build_url: 'https://test.test/mytest', build_image_url: 'https://test.test/mytest.png'
      expect(record.valid?).to be true
    end
  end

  context 'is not valid' do
    it 'without a name' do
      record = described_class.new resource_type: 'local', path: valid_path
      expect(record.valid?).to be false
      expect(record.errors.full_messages).to eq ['Name can\'t be blank']
    end

    it 'without a resource_type' do
      record = described_class.new name: 'Test described_class', path: valid_path
      expect(record.valid?).to be false
      expect(record.errors.full_messages).to eq ['Resource type can\'t be blank']
    end

    it 'without a path' do
      record = described_class.new name: 'Test described_class', resource_type: 'local'
      expect(record.valid?).to be false
      expect(record.errors.full_messages).to eq ['Path can\'t be blank', 'Path must be an absolute path']
    end

    it 'with an non-existing path' do
      record = described_class.new name: 'Test described_class', resource_type: 'local', path: missing_path
      expect(record.valid?).to be false
      expect(record.errors.full_messages).to eq ['Path does not exist']
    end

    it 'with an empty path' do
      FileUtils.mkdir_p missing_path
      record = described_class.new name: 'Test described_class', resource_type: 'local', path: missing_path
      expect(record.valid?).to be false
      expect(record.errors.full_messages).to eq ['Path does not contain Gemfile', 'Path does not contain Gemfile.lock']
    end

    it 'if the same name is used twice' do
      described_class.create name: 'Test described_class', resource_type: 'local', path: valid_path
      record = described_class.new name: 'Test described_class', resource_type: 'local', path: valid_path
      expect(record.valid?).to be false
      expect(record.errors.full_messages).to eq ['Name has already been taken']
    end

    it 'if the build_url is not a url' do
      record = described_class.new name: 'Test described_class', resource_type: 'local', path: valid_path, build_url: 'test.ch/asdf'
      expect(record.valid?).to be false
      expect(record.errors.full_messages).to eq ['Build url must be a valid URL']
    end

    it 'if the build_image_url is not a url' do
      record = described_class.new name: 'Test described_class', resource_type: 'local', path: valid_path, build_image_url: 'test.ch/asdf'
      expect(record.valid?).to be false
      expect(record.errors.full_messages).to eq ['Build image url must be a valid URL']
    end
  end
end
