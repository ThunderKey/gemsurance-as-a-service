require 'rails_helper'

describe 'resources/show.slim' do
  it 'displays the resource correctly' do
    resource = create :resource, name: 'Test Resource'
    assign :resource, resource

    render

    expect(rendered).to match /Test Resource/
  end
end
