# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
@render = (labels, data) ->
  
sameday = (first, second) ->
  first = new Date(first)
  second = new Date(second)
  first.getUTCFullYear() == second.getUTCFullYear() && 
  first.getUTCMonth() == second.getUTCMonth() &&
  first.getUTCDate() == second.getUTCDate()

consolidate = (data) ->
  last_result = null
  results = []
  data.forEach((datum) -> 
    if last_result && sameday(datum.created_at, last_result.created_at)
      last_result.confirmed += datum.confirmed
      last_result.recovered += datum.recovered
      last_result.deaths += datum.deaths
    else
      results.push(datum)
      last_result = datum
    )
  results

@chart = (url) ->
  $.ajax({
    url: url,
    dataType: 'json',
    success: (data, textStatus, jqXHR) ->
      data = consolidate(data)
      ctx = $('#myChart').get(0).getContext('2d')
      myChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: $.map(data, (datum) -> new Date(datum.created_at)),
            datasets: [
              {
                label: 'Confirmed',
                data: $.map(data, (datum) -> datum.confirmed),
                borderWidth: 1,
                cubicInterpolationMode: 'monotone',
                backgroundColor: 'rgba(255, 0, 0, 1)',
                borderColor: 'rgba(255, 0, 0, 1)',
                fill: false
              },
              {
                label: 'Recovered',
                data: $.map(data, (datum) -> datum.recovered),
                borderWidth: 1,
                cubicInterpolationMode: 'monotone',
                backgroundColor: 'rgba(0, 255, 0, 1)',
                borderColor: 'rgba(0, 255, 0, 1)',
                fill: false
              },
              {
                label: 'Deaths',
                data: $.map(data, (datum) -> datum.deaths),
                borderWidth: 1,
                cubicInterpolationMode: 'monotone',
                backgroundColor: 'rgba(0, 0, 0, 1)',
                borderColor: 'rgba(0, 0, 0, 1)',
                fill: false
              }
            ]
        },
        options: {
          scales: {
            xAxes: [{
              type: 'time',
              distribution: 'linear',
              # time: {
              #   parser: 'MM/DD/YYYY HH:mm',
              #   # round: 'day'
              #   tooltipFormat: 'll HH:mm'
              # },
              # scaleLabel: {
              #   display: true,
              #   labelString: 'Date'
              # }
            }],
            yAxes: [{
              ticks: {
                beginAtZero: true
              }
            }]
          }
        }
      })
  })
  