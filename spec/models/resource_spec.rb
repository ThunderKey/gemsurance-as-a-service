# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resource, type: :model do
  valid_path = Rails.root.join('spec', 'assets', 'valid_app').to_s
  missing_path = Rails.application.config.test_tmp_dir.join 'missing_app'

  context 'is valid' do
    it 'with all required attributes' do
      record = described_class.new(
        name: 'Test Resource',
        resource_type: 'local',
        path: valid_path,
        owner: create(:user),
      )
      expect(record).to be_a_valid_record
    end

    it 'with all required and optional attributes' do
      record = described_class.new(
        name: 'Test Resource',
        resource_type: 'local',
        path: valid_path,
        owner: create(:user),
        build_url: 'https://test.test/mytest',
        build_image_url: 'https://test.test/mytest.png',
      )
      expect(record).to be_a_valid_record
    end
  end

  context 'is not valid' do
    it 'without a name' do
      record = described_class.new(
        resource_type: 'local',
        path: valid_path,
        owner: create(:user),
      )
      expect(record).not_to be_a_valid_record
      expect(record.errors.full_messages).to eq ['Name can\'t be blank']
    end

    it 'without a resource_type' do
      record = described_class.new(
        name: 'Test Resource',
        path: valid_path,
        owner: create(:user),
      )
      expect(record).not_to be_a_valid_record
      expect(record.errors.full_messages).to eq ['Resource type can\'t be blank']
    end

    it 'without a owner' do
      record = described_class.new(
        name: 'Test Resource',
        resource_type: 'local',
        path: valid_path,
      )
      expect(record).not_to be_a_valid_record
      expect(record.errors.full_messages).to eq ['Owner must exist']
    end

    it 'without a path' do
      record = described_class.new(
        name: 'Test Resource',
        resource_type: 'local',
        owner: create(:user),
      )
      expect(record).not_to be_a_valid_record
      expect(record.errors.full_messages)
        .to eq ['Path can\'t be blank', 'Path must be an absolute path']
    end

    it 'with an non-existing path' do
      record = described_class.new(
        name: 'Test Resource',
        resource_type: 'local',
        path: missing_path,
        owner: create(:user),
      )
      expect(record).not_to be_a_valid_record
      expect(record.errors.full_messages).to eq ['Path does not exist']
    end

    it 'with a file as a path' do
      FileUtils.touch missing_path
      record = described_class.new(
        name: 'Test Resource',
        resource_type: 'local',
        path: missing_path,
        owner: create(:user),
      )
      expect(record).not_to be_a_valid_record
      expect(record.errors.full_messages).to eq ['Path is not a directory']
    end

    it 'if the same name is used twice' do
      described_class.create(
        name: 'Test Resource',
        resource_type: 'local',
        path: valid_path,
        owner: create(:user),
      )
      record = described_class.new(
        name: 'Test Resource',
        resource_type: 'local',
        path: valid_path,
        owner: create(:user),
      )
      expect(record).not_to be_a_valid_record
      expect(record.errors.full_messages).to eq ['Name has already been taken']
    end

    it 'if the build_url is not a url' do
      record = described_class.new(
        name: 'Test Resource',
        resource_type: 'local',
        path: valid_path,
        owner: create(:user),
        build_url: 'test.ch/asdf',
      )
      expect(record).not_to be_a_valid_record
      expect(record.errors.full_messages).to eq ['Build url must be a valid URL']
    end

    it 'if the build_image_url is not a url' do
      record = described_class.new(
        name: 'Test Resource',
        resource_type: 'local',
        path: valid_path,
        owner: create(:user),
        build_image_url: 'test.ch/asdf',
      )
      expect(record).not_to be_a_valid_record
      expect(record.errors.full_messages).to eq ['Build image url must be a valid URL']
    end
  end

  describe '#gem_status' do
    subject(:resource) { create :empty_local_resource }

    it 'handles the current status correctly' do
      expect(resource.gem_status).to eq :current

      resource.gem_versions << create(:gem_version)
      resource.gem_versions << create(:gem_version)
      resource.gem_versions << create(:gem_version)
      expect(resource.gem_status).to eq :current
      expect(resource.numeric_gem_status).to eq 2
      expect(resource.gem_versions.outdated.count).to eq 0
    end

    it 'handles the outdated status correctly' do
      info = create :gem_info
      create :gem_version, gem_info: info, version: '1.2.4'
      resource.gem_versions << create(:gem_version)
      resource.gem_versions << create(:gem_version, gem_info: info, version: '1.2.3')
      resource.gem_versions << create(:gem_version)
      expect(resource.gem_status).to eq :current
      expect(resource.numeric_gem_status).to eq 2
      expect(resource.gem_versions.outdated.count).to eq 1
    end

    it 'handles the vulnerable status correctly' do
      info = create :gem_info
      resource.gem_versions << create(:gem_version)
      resource.gem_versions << create(:gem_version, gem_info: info, version: '1.2.3')
      resource.gem_versions << create(:gem_version)
      create :vulnerability, gem_version: resource.gem_versions.last
      resource.reload
      expect(resource.gem_status).to eq :vulnerable
      expect(resource.numeric_gem_status).to eq 0
      expect(resource.gem_versions.outdated.count).to eq 0
    end

    it 'handles the vulnerable status correctly if it uses an existing version' do
      info = create :gem_info
      resource.gem_versions << create(:gem_version)
      resource.gem_versions << create(:gem_version, gem_info: info, version: '1.2.3')
      resource.gem_versions << create(:gem_version, :vulnerable)

      resource.reload
      expect(resource.gem_status).to eq :vulnerable
      expect(resource.numeric_gem_status).to eq 0
      expect(resource.gem_versions.outdated.count).to eq 0
    end

    it 'unknown' do
      # 2 times because checking the value and again in the raise statement
      expect(resource).to receive(:gem_status).twice.and_return :unknown
      expect {resource.numeric_gem_status}.to raise_error 'Unsupported gem_status :unknown'
    end
  end

  describe '#sort_by_gem_status' do
    subject(:gem_stati) { described_class.all }

    before do
      3.times do |i|
        # current
        create(:empty_local_resource, name: "Current App #{i}") do |resource|
          resource.gem_versions << create(:gem_version)
          resource.gem_versions << create(:gem_version)
          resource.gem_versions << create(:gem_version)
        end

        # outdated
        create(:empty_local_resource, name: "Outdated App #{i}") do |resource|
          info = create :gem_info
          create :gem_version, gem_info: info, version: '1.2.4'
          resource.gem_versions << create(:gem_version)
          resource.gem_versions << create(:gem_version, gem_info: info, version: '1.2.3')
          resource.gem_versions << create(:gem_version)
        end

        # vulnerable
        create(:empty_local_resource, name: "Vulnerable App #{i}") do |resource|
          info = create :gem_info
          create :gem_version, gem_info: info, version: '1.2.4'
          resource.gem_versions << create(:gem_version)
          resource.gem_versions << create(:gem_version, gem_info: info, version: '1.2.3')
          resource.gem_versions << create(:gem_version)
          create :vulnerability, gem_version: resource.gem_versions.last
        end
      end
    end

    it 'has a different default order' do
      expect(gem_stati.map(&:name)).to eq [
        'Current App 0', 'Outdated App 0', 'Vulnerable App 0',
        'Current App 1', 'Outdated App 1', 'Vulnerable App 1',
        'Current App 2', 'Outdated App 2', 'Vulnerable App 2'
      ]
    end

    it 'sorts default ascending' do
      expect(gem_stati.sort_by_gem_status.map(&:name)).to eq [
        'Vulnerable App 0', 'Vulnerable App 1', 'Vulnerable App 2',
        'Current App 0', 'Outdated App 0',
        'Current App 1', 'Outdated App 1',
        'Current App 2', 'Outdated App 2'
      ]
    end

    it 'sorts ascending' do
      expect(gem_stati.sort_by_gem_status(:asc).map(&:name)).to eq [
        'Vulnerable App 0', 'Vulnerable App 1', 'Vulnerable App 2',
        'Current App 0', 'Outdated App 0',
        'Current App 1', 'Outdated App 1',
        'Current App 2', 'Outdated App 2'
      ]
    end

    it 'sorts descending' do
      expect(gem_stati.sort_by_gem_status(:desc).map(&:name)).to eq [
        'Current App 0', 'Outdated App 0',
        'Current App 1', 'Outdated App 1',
        'Current App 2', 'Outdated App 2',
        'Vulnerable App 0', 'Vulnerable App 1', 'Vulnerable App 2'
      ]
    end

    it 'raises an error with an invalid direction' do
      expect {gem_stati.sort_by_gem_status(:invalid)}
        .to raise_error 'Unknown direction :invalid. Available: :asc and :desc'
    end
  end

  it 'generates the correct resource_type data' do
    expect(described_class.resource_types).to eq('local' => 'local')
    expect(described_class.resource_types.keys).to eq GemsuranceService.fetchers.keys
    expect(described_class.resource_type_attributes_for_select).to eq [
      %w(Local local),
    ]
  end

  describe 'update the vulnerabilities_count' do
    subject(:resource) { create :resource }

    it 'updates if vulnerabilities get added and removed to/from an existing gem version' do
      expect do
        resource.gem_versions.each.with_index do |v, i|
          (i + 1).times { create :vulnerability, gem_version: v }
        end
      end.to change { resource.reload.vulnerabilities_count }.by 6

      expect do
        resource.gem_versions.each do |v|
          v.vulnerabilities.last!.destroy
        end
      end.to change { resource.reload.vulnerabilities_count }.by(-3)
    end
  end
end
