# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'gem_versions/show.slim' do
  it 'displays the gem version correctly' do
    gem_version = create :gem_version
    r = create :resource
    r.gem_usages.create gem_version: gem_version

    assign :gem_version, gem_version

    render

    expect(rendered)
      .to match %r{<h1><a href="/gems/#{gem_version.gem_info.id}">TestGem#1</a> - 1\.2\.3</h1>}
    expect(rendered).to match %r{>Test App 1</a>}
    expect(rendered).not_to match %r{><h2>Vulnerabilities</h2>}
  end

  it 'displays a gem version with vulnerabilities correctly' do
    gem_version = create :gem_version
    gem_version.vulnerabilities.create description: 'Vulnerability 1'
    gem_version.vulnerabilities.create description: 'Vulnerability 2', url: 'https://example.com/vulnerability2'
    r = create :resource
    r.gem_usages.create gem_version: gem_version

    assign :gem_version, gem_version

    render

    expect(rendered)
      .to match %r{<h1><a href="/gems/#{gem_version.gem_info.id}">TestGem#1</a> - 1\.2\.3</h1>}
    expect(rendered).to match %r{>Test App 1</a>}
    expect(rendered).to match %r{><h2>Vulnerabilities</h2>}
    expect(rendered).to match %r{<li class="title small">Vulnerability 1</li>}
    link = %Q{<a target="_blank" href="https://example\.com/vulnerability2">Vulnerability 2</a>}
    expect(rendered).to match %r{<li class="title small">#{link}</li>}
  end
end
