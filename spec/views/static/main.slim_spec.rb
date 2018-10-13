# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'static/main.slim' do
  it 'gets rendered correctly' do
    render

    expect(rendered).to match %r{<h1>Gemsurance As A Service</h1>}
  end
end
