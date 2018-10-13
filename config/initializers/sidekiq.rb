# frozen_string_literal: true

def configure_sidekiq config
  config.redis = {
    host:       Rails.application.config.redis.host!,
    port:       Rails.application.config.redis.port!,
    db:         Rails.application.config.redis.database!,
    namespace:  Rails.application.config.redis.sidekiq_namespace!,
  }
end

Sidekiq.configure_server {|c| configure_sidekiq c }
Sidekiq.configure_client {|c| configure_sidekiq c }

Sidekiq.default_worker_options = {retry: false}

if Rails.env.development?
  require 'sidekiq/testing'
  Sidekiq::Testing.inline!
end
