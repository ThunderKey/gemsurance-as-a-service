#= require chart.js/Chart.bundle.js
#= require_self

window.drawChart = (id, type, data, options = {}) ->
  new Chart document.getElementById(id),
    {type: type, data: data, options: options}
