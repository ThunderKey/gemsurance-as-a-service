require 'rails_helper'

describe 'resources/index.slim' do
  it 'displays all resources correctly' do
    assign :resources, 3.times.map { create :resource }

    render

    expect(rendered).to match /Test App 1/
    expect(rendered).to match /Test App 2/
    expect(rendered).to match /Test App 3/
  end
end
