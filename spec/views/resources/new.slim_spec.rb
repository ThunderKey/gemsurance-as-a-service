# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'resources/new.slim' do
  it 'displays the form correctly' do
    assign :resource, Resource.new

    render

    expect(rendered).to match %r{>Name</label>}
    expect(rendered).to match %r{>Build url</label>}
    expect(rendered).to match %r{>Build image url</label>}
    expect(rendered).to match %r{>Resource type</label>}
    expect(rendered).to match %r{>Path</label>}
  end
end
