require 'rails_helper'

describe 'resources/new.slim' do
  it 'displays the form correctly' do
    assign :resource, Resource.new

    render

    expect(rendered).to match />Name<\/label>/
    expect(rendered).to match />Build url<\/label>/
    expect(rendered).to match />Build image url<\/label>/
    expect(rendered).to match />Resource type<\/label>/
    expect(rendered).to match />Path<\/label>/
  end
end
