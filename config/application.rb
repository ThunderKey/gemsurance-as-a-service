require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GemsuranceAsAService
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.active_job.queue_adapter = :sidekiq

    config.url_regex = /\A#{URI::regexp(['http', 'https'])}\z/
    config.git_command = '/usr/bin/git'
    config.private_dir = File.join Rails.root, 'private'

    config.redis = ActiveSupport::OrderedOptions.new
    config.redis.host = 'localhost'
    config.redis.port = 6379
    config.redis.sidekiq_namespace = "gaas_sidekiq"

    console do
      ActiveRecord::Base.connection
    end
  end
end
