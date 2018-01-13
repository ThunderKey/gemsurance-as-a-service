RSpec.configure do |config|
  include Warden::Test::Helpers

  config.before(with_login: true) do
    login_as create(:user), scope: :user
  end

  def sign_in(resource_or_scope, resource = nil)
    resource ||= resource_or_scope
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    login_as(resource, scope: scope)
  end

  def sign_out(resource_or_scope)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    logout(scope)
  end

  config.include Devise::Test::ControllerHelpers, type: :controller
  def stub_devise user = nil
    user ||= create :user
    allow(request.env['warden']).to receive(:authenticate!).and_return(user)
    allow(controller).to receive(:current_user).and_return(user)
  end
end
