# frozen_string_literal: true

require 'rails_helper'
# https://everydayrails.com/2012/04/07/testing-series-rspec-controllers.html

RSpec.describe GemInfosController do
  before do
    stub_devise
  end

  describe 'GET #index' do
    it 'displays 0 gem_infos' do
      get :index
      expect(assigns(:gem_infos)).to eq []
    end

    it 'displays 3 gem_infos' do
      g1 = create :gem_info
      g2 = create :gem_info
      g3 = create :gem_info
      create :gem_version, gem_info: g3, version: '0.0.1'
      create :gem_version, gem_info: g3, version: '0.0.2'

      get :index
      expect(assigns(:gem_infos)).to eq [g1, g2, g3]
      expect(assigns(:current_gem_infos)).to eq [g1, g2]
      expect(assigns(:outdated_gem_infos)).to eq [g3]
    end

    it 'renders the :index view' do
      get :index
      expect(response).to render_template :index
    end
  end

  describe 'GET #show' do
    it 'assigns the requested gem_info to @gem_info' do
      gem_info = create :gem_info
      versions = Array.new(3) { create :gem_version, gem_info: gem_info }
      create(:empty_local_resource).gem_usages.create gem_version: versions[1]
      create(:empty_local_resource).gem_usages.create gem_version: versions[1]
      create(:empty_local_resource).gem_usages.create gem_version: versions[2]
      get :show, params: {id: gem_info}
      expect(assigns(:gem_info)).to eq(gem_info)
      expect(assigns(:versions_data)).to eq(
        labels: ['1.2.3', '2.3.4', '3.4.5'],
        datasets: [
          {
            data: [0, 2, 1],
            backgroundColor: ['#FF6666', '#66FF66', '#6666FF'],
            hoverBackgroundColor: ['#FF6666', '#66FF66', '#6666FF'],
          },
        ],
      )
    end

    it 'renders the #show view' do
      get :show, params: {id: create(:gem_info)}
      expect(response).to render_template :show
    end
  end
end
