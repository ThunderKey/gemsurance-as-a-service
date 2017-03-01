RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.before(:each) do
    FactoryGirl.reload
  end
end
