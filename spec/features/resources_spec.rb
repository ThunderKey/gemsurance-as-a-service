# frozen_string_literal: true

require 'rails_helper'

RSpec.feature '/resources', with_login: true do
  let(:base_url) { '/resources' }

  it 'displays all resources correctly' do
    3.times { create :resource }

    visit base_url

    expect(page).to have_content 'Test App 1'
    expect(page).to have_content 'Test App 2'
    expect(page).to have_content 'Test App 3'
  end

  context '/:id' do
    it 'displays the resource correctly' do
      resource = create :resource, name: 'Test Resource'

      visit "#{base_url}/#{resource.id}"

      expect(page).to have_content 'Test Resource'
      expect(page).to have_content 'TestGem#1'
      expect(page).to have_content 'TestGem#2'
      expect(page).to have_content 'TestGem#3'
      expect(page).to_not have_selector 'tr.outdated'
      expect(page).to_not have_selector 'tr.vulnerable'
    end

    it 'displays the resource correctly with an outdated gem' do
      resource = create :resource, name: 'Test Resource'
      create :gem_version, gem_info: resource.gem_versions.last.gem_info # make one version outdated

      visit "#{base_url}/#{resource.id}"

      expect(page).to have_content 'Test Resource'
      expect(page).to have_content 'TestGem#1'
      expect(page).to have_content 'TestGem#2'
      expect(page).to have_content 'TestGem#3'
      expect(page).to have_selector 'tr.outdated'
      expect(page).to_not have_selector 'tr.vulnerable'
    end

    it 'displays the resource correctly with a vulnerable gem' do
      resource = create :resource, name: 'Test Resource'
      2.times do
        create :vulnerability, gem_version: resource.gem_versions.first!
      end
      3.times do
        create :vulnerability, gem_version: resource.gem_versions.last!
      end

      visit "#{base_url}/#{resource.id}"

      expect(page).to have_content 'Test Resource'
      expect(page).to have_content 'TestGem#1'
      expect(page).to have_content 'TestGem#2'
      expect(page).to have_content 'TestGem#3'
      expect(page).to_not have_selector 'tr.outdated'
      expect(page).to have_selector 'tr.vulnerable'
    end

    context '/edit' do
      it 'displays the resource to edit correctly' do
        resource = create :resource, name: 'Test Resource'

        visit "#{base_url}/#{resource.id}/edit"

        expect(find_field('resource[name]').value).to eq 'Test Resource'

        fill_in 'Name', with: 'MyTestResource'
        fill_in 'Build url', with: 'http://example.com/my-test-resource'
        fill_in 'Build image url', with: 'http://example.com/my-test-resource.png'
        select 'Local', from: 'Resource type'
        fill_in 'Path', with: File.join(Rails.root, 'spec', 'assets', 'valid_app')

        click_button 'Update Resource'

        resource.reload
        expect(resource.name).to eq 'MyTestResource'
        expect(resource.build_url).to eq 'http://example.com/my-test-resource'
        expect(resource.build_image_url).to eq 'http://example.com/my-test-resource.png'
        expect(resource.resource_type).to eq 'local'
        expect(resource.path).to eq File.join(Rails.root, 'spec', 'assets', 'valid_app')
      end
    end
  end

  context '/new' do
    it 'displays the form correctly' do
      visit "#{base_url}/new"

      fill_in 'Name', with: 'MyTestResource'
      fill_in 'Build url', with: 'http://example.com/my-test-resource'
      fill_in 'Build image url', with: 'http://example.com/my-test-resource.png'
      select 'Local', from: 'Resource type'
      fill_in 'Path', with: File.join(Rails.root, 'spec', 'assets', 'valid_app')

      expect do
        click_button 'Create Resource'
        expect(page).to have_content 'Successfuly saved "MyTestResource"'
      end.to change { Resource.count }.by 1

      resource = Resource.last
      expect(resource.name).to eq 'MyTestResource'
      expect(resource.build_url).to eq 'http://example.com/my-test-resource'
      expect(resource.build_image_url).to eq 'http://example.com/my-test-resource.png'
      expect(resource.resource_type).to eq 'local'
      expect(resource.path).to eq File.join(Rails.root, 'spec', 'assets', 'valid_app')
    end
  end
end
