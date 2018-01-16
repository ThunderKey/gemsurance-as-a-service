#!/usr/bin/env ruby

SimpleCov.start do
  # track any files in app or lib
  track_files '{app,lib}/**/*.*'

  add_filter '/spec/'
  add_filter "/config/"
  add_filter "/db/"
  add_filter "/app/views/"
  add_filter "/app/assets/"

  add_group "Controllers", "app/controllers"
  add_group "Models", "app/models"
  add_group "Mailers", "app/mailers"
  add_group "Helpers", "app/helpers"
  add_group "Jobs", %w(app/jobs app/workers)
  add_group "Channels", "app/channels"
  add_group "Services", "app/services"
  add_group "Libraries", "lib"
end
