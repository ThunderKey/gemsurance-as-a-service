#= require jquery/dist/jquery
#= require jquery.turbolinks
#= require jquery-ujs/src/rails
#= require foundation/foundation_and_overrides
#= require charts
#= require cable
#= require_self
#= require turbolinks

initPage = () ->
  console.debug 'init'
  $(document).foundation()

  # Fix for stiky with turbolinks
  $(window).trigger 'load.zf.sticky'

$(document).on 'turbolinks:load', initPage
