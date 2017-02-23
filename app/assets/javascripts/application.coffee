#= require jquery/dist/jquery
#= require jquery-ujs/src/rails
#= require foundation-sites/dist/foundation
#= require charts
#= require cable
#= require_self
#= require turbolinks

ready = () ->
  $(document).foundation()

$(document).on('turbolinks:load', ready)
