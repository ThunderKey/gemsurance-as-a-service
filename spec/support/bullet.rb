RSpec.configure do |config|
  unless ENV['SKIP_BULLET'] == 'true'
    config.around(:each) do |example|
      Bullet.profile { example.run }
    end
  end
end
