RSpec.configure do |config|
  config.around(:each) do |example|
    Bullet.profile { example.run }
  end
end
