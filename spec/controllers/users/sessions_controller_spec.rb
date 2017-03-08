require 'rails_helper'

RSpec.describe Users::SessionsController do
  before :each do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe 'GET #new' do
    it 'automatically logs the user in via accounts.keltec.ch if no flash message is present' do
      get :new
      expect(response).to redirect_to user_keltec_omniauth_authorize_path
    end

    it 'displays the login page if a flash message is present' do
      get :new, flash: {notice: 'Test Notice'}
      expect(response).to render_template :new
    end
  end
end
