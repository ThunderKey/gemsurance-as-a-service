# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'resources/show.slim' do
  it 'displays the resource correctly' do
    resource = create :resource, name: 'Test Resource'
    assign :resource, resource

    render

    expect(rendered).to match /Test Resource/
    expect(rendered).to match /TestGem#1/
    expect(rendered).to match /TestGem#2/
    expect(rendered).to match /TestGem#3/
    expect(rendered).to_not match /outdated/
    expect(rendered).to_not match /vulnerable/
  end

  it 'displays the resource correctly with an outdated gem' do
    resource = create :resource, name: 'Test Resource'
    create :gem_version, gem_info: resource.gem_versions.last.gem_info # make one version outdated
    assign :resource, resource

    render

    expect(rendered).to match /Test Resource/
    expect(rendered).to match /TestGem#1/
    expect(rendered).to match /TestGem#2/
    expect(rendered).to match %r{<tr class="outdated"[^>]*><td><a[^>]*>TestGem#3</a>}
    expect(rendered).to_not match /vulnerable/
  end

  it 'displays the resource correctly with an outdated gem' do
    resource = create :resource, name: 'Test Resource'
    2.times do
      create :vulnerability, gem_version: resource.gem_versions.first!
    end
    3.times do
      create :vulnerability, gem_version: resource.gem_versions.last!
    end
    assign :resource, resource

    render

    expect(rendered).to match /Test Resource/
    expect(rendered).to match %r{<tr class="vulnerable"[^>]*><td><a[^>]*>TestGem#1</a>}
    expect(rendered).to match /TestGem#2/
    expect(rendered).to match %r{<tr class="vulnerable"[^>]*><td><a[^>]*>TestGem#3</a>}
    expect(rendered).to_not match /outdated/
  end
end
