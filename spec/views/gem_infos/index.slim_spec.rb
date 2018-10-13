# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'gem_infos/index.slim' do
  it 'displays all gems correctly' do
    gem_infos = Array.new(3) { create(:gem_info) }
    assign :gem_infos, Array.new(3) { create(:gem_info) }
    assign :outdated_gem_infos, gem_infos[0..1]
    assign :current_gem_infos, gem_infos[2..2]

    render

    expect(rendered).to match %r{>TestGem#1</a>}
    expect(rendered).to match %r{>TestGem#2</a>}
    expect(rendered).to match %r{>TestGem#3</a>}
  end
end
