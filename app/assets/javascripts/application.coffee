#= require jquery
#= require jquery.turbolinks
#= require jquery-ujs
#= require foundation/_foundation_and_overrides
#= require _charts
#= require _cable
#= require_self
#= require turbolinks

initPage = () ->
  $(document).foundation()

  # Fix for stiky with turbolinks
  $(window).trigger 'load.zf.sticky'

$(document).on 'turbolinks:load', initPage
