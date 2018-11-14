# frozen_string_literal: true

RSpec.configure do |config|
  unless ENV['SKIP_BULLET'] == 'true'
    config.around do |example|
      Bullet.profile { example.run }
    end
  end
end
