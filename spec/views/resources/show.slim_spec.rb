require 'rails_helper'

RSpec.describe 'resources/show.slim' do
  it 'displays the resource correctly' do
    resource = create :resource, name: 'Test Resource'
    assign :resource, resource

    render

    expect(rendered).to match %r{Test Resource}
    expect(rendered).to match %r{TestGem#1}
    expect(rendered).to match %r{TestGem#2}
    expect(rendered).to match %r{TestGem#3}
    expect(rendered).not_to match %r{outdated}
    expect(rendered).not_to match %r{vulnerable}
  end

  it 'displays the resource correctly with an outdated gem' do
    resource = create :resource, name: 'Test Resource'
    create :gem_version, gem_info: resource.gem_versions.last.gem_info # make one version outdated
    assign :resource, resource

    render

    expect(rendered).to match %r{Test Resource}
    expect(rendered).to match %r{TestGem#1}
    expect(rendered).to match %r{TestGem#2}
    expect(rendered).to match %r{<tr class="outdated"[^>]*><td><a[^>]*>TestGem#3</a>}
    expect(rendered).not_to match %r{vulnerable}
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

    expect(rendered).to match %r{Test Resource}
    expect(rendered).to match %r{<tr class="vulnerable"[^>]*><td><a[^>]*>TestGem#1</a>}
    expect(rendered).to match %r{TestGem#2}
    expect(rendered).to match %r{<tr class="vulnerable"[^>]*><td><a[^>]*>TestGem#3</a>}
    expect(rendered).not_to match %r{outdated}
  end
end
