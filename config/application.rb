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

    config.url_regex = /\A#{URI::regexp(['http', 'https'])}\z/
    config.git_command = '/usr/bin/git'
    config.private_dir = File.join Rails.root, 'private'
    config.gemfile_dir = File.join config.private_dir, 'gemfiles'
    config.ruby_advisory_database_dir = File.join config.private_dir, 'ruby_advisory_database'
    config.ruby_advisory_database_repository = 'https://github.com/rubysec/ruby-advisory-db.git'
  end
end
