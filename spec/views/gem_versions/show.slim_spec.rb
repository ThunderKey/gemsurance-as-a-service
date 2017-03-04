require 'rails_helper'

describe 'gem_versions/show.slim' do
  it 'displays the gem version correctly' do
    gem_version = create :gem_version
    r = create :resource
    r.gem_usages.create gem_version: gem_version

    assign :gem_version, gem_version

    render

    expect(rendered).to match /<h1>TestGem#1 - 1\.2\.3<\/h1>/
    expect(rendered).to match />Test App 1<\/a>/
  end
end
