require 'rails_helper'

RSpec.describe Resource, type: :model do
  valid_path = File.join Rails.root, 'spec', 'assets', 'valid_app'
  missing_path = File.join Rails.application.config.test_tmp_dir, 'missing_app'

  it 'is valid with valid attributes' do
    resource = Resource.new name: 'Test Resource', resource_type: 'local', path: valid_path
    expect(resource.valid?).to be true
  end

  it 'is not valid without a name' do
    resource = Resource.new resource_type: 'local', path: valid_path
    expect(resource.valid?).to be false
    expect(resource.errors.full_messages).to eq ['Name can\'t be blank']
  end

  it 'is not valid without a resource_type' do
    resource = Resource.new name: 'Test Resource', path: valid_path
    expect(resource.valid?).to be false
    expect(resource.errors.full_messages).to eq ['Resource type can\'t be blank']
  end

  it 'is not valid without a path' do
    resource = Resource.new name: 'Test Resource', resource_type: 'local'
    expect(resource.valid?).to be false
    expect(resource.errors.full_messages).to eq ['Path can\'t be blank', 'Path must be an absolute path']
  end

  it 'is not valid with an non-existing path' do
    resource = Resource.new name: 'Test Resource', resource_type: 'local', path: missing_path
    expect(resource.valid?).to be false
    expect(resource.errors.full_messages).to eq ['Path does not exist']
  end

  it 'is not valid with an empty path' do
    FileUtils.mkdir_p missing_path
    resource = Resource.new name: 'Test Resource', resource_type: 'local', path: missing_path
    expect(resource.valid?).to be false
    expect(resource.errors.full_messages).to eq ['Path does not contain Gemfile', 'Path does not contain Gemfile.lock']
  end

  it 'is not valid if the same name is used twice' do
    Resource.create name: 'Test Resource', resource_type: 'local', path: valid_path
    resource = Resource.new name: 'Test Resource', resource_type: 'local', path: valid_path
    expect(resource.valid?).to be false
    expect(resource.errors.full_messages).to eq ['Name has already been taken']
  end
end
