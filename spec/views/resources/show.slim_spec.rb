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
  end

  it 'displays the resource correctly with an outdated gem' do
    resource = create :resource, name: 'Test Resource'
    create :gem_version, gem_info: resource.gem_versions.last.gem_info # make one version outdated
    assign :resource, resource

    render

    expect(rendered).to match %r{Test Resource}
    expect(rendered).to match %r{TestGem#1}
    expect(rendered).to match %r{TestGem#2}
    expect(rendered).to match %r{TestGem#3}
    expect(rendered).to match %r{<tr class="outdated"[^>]*><td><a[^>]*>TestGem#3</a>}
  end
end
