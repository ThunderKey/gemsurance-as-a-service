require 'rails_helper'

RSpec.describe 'gems/index.slim' do
  it 'displays all gems correctly' do
    assign :gem_infos, 3.times.map { create(:gem_info) }

    render

    expect(rendered).to match />TestGem#1<\/a>/
    expect(rendered).to match />TestGem#2<\/a>/
    expect(rendered).to match />TestGem#3<\/a>/
  end
end
