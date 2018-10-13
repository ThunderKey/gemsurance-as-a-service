# frozen_string_literal: true

require 'rails_helper'
# https://everydayrails.com/2012/04/07/testing-series-rspec-controllers.html

RSpec.describe GemVersionsController do
  before :each do
    stub_devise
  end

  describe 'GET #show' do
    it 'assigns the requested gem_info to @gem_info' do
      gem_version = create :gem_version, gem_info: create(:gem_info)
      get :show, params: {id: gem_version, gem_info_id: gem_version.gem_info}
      expect(assigns(:gem_version)).to eq(gem_version)
    end

    it 'renders the #show view' do
      gem_version = create :gem_version, gem_info: create(:gem_info)
      get :show, params: {id: gem_version, gem_info_id: gem_version.gem_info}
      expect(response).to render_template :show
    end
  end
end
