require 'rails_helper'

RSpec.describe 'gem_infos/index.slim' do
  it 'displays all gems correctly' do
    gem_infos = 3.times.map { create(:gem_info) }
    assign :gem_infos, 3.times.map { create(:gem_info) }
    assign :outdated_gem_infos, gem_infos[0..1]
    assign :current_gem_infos, gem_infos[2..2]

    render

    expect(rendered).to match />TestGem#1<\/a>/
    expect(rendered).to match />TestGem#2<\/a>/
    expect(rendered).to match />TestGem#3<\/a>/
  end
end
