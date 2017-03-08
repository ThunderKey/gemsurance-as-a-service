require 'rails_helper'

RSpec.describe 'resources/edit.slim' do
  it 'displays the resource to edit correctly' do
    resource = create :resource, name: 'Test Resource'
    assign :resource, resource

    render

    expect(rendered).to match /Test Resource/
  end
end
