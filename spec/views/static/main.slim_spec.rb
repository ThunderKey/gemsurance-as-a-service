require 'rails_helper'

describe 'static/main.slim' do
  it 'gets rendered correctly' do
    render

    expect(rendered).to match /<h1>Gemsurance As A Service<\/h1>/
  end
end
