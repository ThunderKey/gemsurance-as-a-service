# frozen_string_literal: true

require 'rails_helper'

RSpec.feature '/', with_login: true do
  let(:base_url) { '/' }

  it 'gets rendered correctly' do
    visit base_url

    within 'h1' do
      expect(page).to have_content 'Gemsurance As A Service'
    end
  end
end
