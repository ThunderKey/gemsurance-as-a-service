require 'rails_helper'

describe Users::OmniauthCallbacksController do
  before :each do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    hash = OmniAuth::AuthHash.new(provider: 'keltec', uid: 1234)
    hash.info = {
      id: 1234,
      email: 'walter.smith@example.com',
      lastname: 'Smith',
      firstname: 'Walter',
    }
    @request.env['omniauth.auth'] = hash
  end

  describe 'GET #new' do
    it 'creates a new user if it doesnt exist yet' do
      expect { get :keltec }.to change{User.count}.by 1
      expect(response).to redirect_to root_path
      expect(flash.to_hash).to eq('notice'=>'Successfully authenticated from Keltec account.')

      user = User.last
      expect(user.email).to eq 'walter.smith@example.com'
      expect(user.lastname).to eq 'Smith'
      expect(user.firstname).to eq 'Walter'
    end

    it 'users the existing user if it exists' do
      user = create :user, provider: 'keltec', uid: 1234
      expect(user.email).to eq 'peter.tester@example.com'

      expect { get :keltec }.not_to change{User.count}
      expect(response).to redirect_to root_path
      expect(flash.to_hash).to eq('notice'=>'Successfully authenticated from Keltec account.')

      user.reload
      expect(user.email).to eq 'walter.smith@example.com'
      expect(user.lastname).to eq 'Smith'
      expect(user.firstname).to eq 'Walter'
    end
  end
end
