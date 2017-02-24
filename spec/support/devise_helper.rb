RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  def stub_devise user = nil
    user ||= create :user
    allow(request.env['warden']).to receive(:authenticate!).and_return(user)
    allow(controller).to receive(:current_user).and_return(user)
  end
end
