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
    expect(rendered).not_to match /><h2>Vulnerabilities<\/h2>/
  end

  it 'displays a gem version with vulnerabilities correctly' do
    gem_version = create :gem_version
    gem_version.vulnerabilities.create description: 'Vulnerability 1'
    gem_version.vulnerabilities.create description: 'Vulnerability 2', url: 'https://example.com/vulnerability2'
    r = create :resource
    r.gem_usages.create gem_version: gem_version

    assign :gem_version, gem_version

    render

    expect(rendered).to match %r{<h1>TestGem#1 - 1\.2\.3</h1>}
    expect(rendered).to match %r{>Test App 1</a>}
    expect(rendered).to match %r{><h2>Vulnerabilities</h2>}
    expect(rendered).to match %r{<td>Vulnerability 1</td>}
    expect(rendered).to match %r{<td><a href="https://example\.com/vulnerability2">Vulnerability 2</a></td>}
  end
end
