# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'resources/index.slim' do
  it 'displays all resources correctly' do
    create_list :resource, 3
    assign :resources, Resource.all

    render

    expect(rendered).to match /Test App 1/
    expect(rendered).to match /Test App 2/
    expect(rendered).to match /Test App 3/
  end
end
