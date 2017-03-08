require 'rails_helper'

RSpec.describe 'gems/show.slim' do
  it 'displays the gem correctly' do
    assign :gem_info, create(:gem_info)
    assign :versions_data, {
      labels: ['Test'],
      datasets: [
        {
          data: [5],
          backgroundColor: ['#FF0000'],
          hoverBackgroundColor: ['#FF0000'],
        }
      ],
    }

    render

    expect(rendered).to match /<h1>TestGem#1<\/h1>/
  end
end
