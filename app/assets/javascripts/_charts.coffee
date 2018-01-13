#= require chart.js/Chart.bundle.js
#= require_self

window.drawChart = (id, type, data, options = {}) ->
  setupMethod = ->
    $(document).off 'turbolinks:load', setupMethod
    new Chart document.getElementById(id),
      {type: type, data: data, options: options}
  $(document).on 'turbolinks:load', setupMethod
