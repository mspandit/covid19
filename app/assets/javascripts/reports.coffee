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
      last_result.deaths += datum.deaths
    else
      results.push(datum)
      last_result = datum
    )
  results

with_data = (url, handler) ->
  $.ajax({
    url: url,
    dataType: 'json',
    success: (data, textStatus, jqXHR) ->
      handler(data)
  })

redraw = (chart, stacked) ->
    chart.data.datasets.forEach((dataset) ->
      dataset.fill = stacked
    )
    chart.options = {
      scales: {
        xAxes: [{
          type: 'time',
          distribution: 'linear',
        }],
        yAxes: [{
          ticks: {
            beginAtZero: true
          },
          stacked: stacked
        }]
      }
    }
    chart.update()
  
chart = (canvas, stacked) ->
  ctx = canvas.get(0).getContext('2d')
  ctx.clearRect(0, 0, canvas.width, canvas.height)
  return new Chart(ctx, {
    type: 'line',
    data: {
        labels: []
        datasets: []
    },
    options: {
      scales: {
        xAxes: [{
          type: 'time',
          distribution: 'linear',
        }],
        yAxes: [{
          ticks: {
            beginAtZero: true
          },
          stacked: stacked
        }]
      }
    }
  })

datasetConfig = (label, data, color, fill, pointStyle) ->
  {
    label: label,
    data: data,
    borderWidth: 1,
    cubicInterpolationMode: 'monotone',
    backgroundColor: color,
    borderColor: color,
    fill: fill,
    pointStyle: pointStyle
  }

merge = (data1, data2) ->
  merged = []
  data1.forEach((datum) ->
    merged.push(
      {
        created_at: datum.created_at,
        confirmed1: datum.confirmed,
        deaths1: datum.deaths,
        confirmed2: NaN,
        deaths2: NaN
      }
    )
  )
  data2.forEach((datum)->
    merged.push(
      {
        created_at: datum.created_at,
        confirmed2: datum.confirmed,
        deaths2: datum.deaths,
        confirmed1: NaN,
        deaths1: NaN
      }
    )
  )
  merged.sort((d1, d2) -> 
    if d1.created_at < d2.created_at
      -1
    else if d1.created_at > d2.created_at
      1
    else
      0
  )
  console.log(merged)
  merged

@ReportChart2 = (loading_id, chart_id, stacked_id, pointStyle1, pointStyle2) ->
  self = this

  if stacked_id
    $(stacked_id).change((event) ->
      self.redraw(this.checked)
    )
    self.chart = chart($(chart_id + ' canvas'), $(stacked_id).get(0).checked)
  else
    self.chart = chart($(chart_id + ' canvas'), false)

  self.redraw = (stacked) ->
    redraw(self.chart, stacked)
  
  self.updateData = (label1, url1, label2, url2) ->
    fill = if stacked_id
      $(stacked_id).get(0).checked
    else
      false
    $(chart_id).hide()
    $(loading_id).show()
    with_data(url1, (data1) ->
      with_data(url2, (data2) ->
        data1 = consolidate(data1)
        data2 = consolidate(data2)
        data = merge(data1, data2)
        $(loading_id).hide()
        $(chart_id).show()
        self.chart.data.labels = $.map(data, (datum) -> new Date(datum.created_at))
        self.chart.data.datasets = [
          datasetConfig(label1 + ' Confirmed', $.map(data, (datum) -> datum.confirmed1 || NaN), 'rgba(255, 0, 0, 1)', fill, pointStyle1),
          datasetConfig(label1 + ' Deaths',    $.map(data, (datum) -> datum.deaths1 || NaN),    'rgba(0, 0, 0, 1)',   fill, pointStyle1),
          datasetConfig(label2 + ' Confirmed', $.map(data, (datum) -> datum.confirmed2 || NaN), 'rgba(255, 0, 0, 1)', fill, pointStyle2),
          datasetConfig(label2 + ' Deaths',    $.map(data, (datum) -> datum.deaths2 || NaN),    'rgba(0, 0, 0, 1)',   fill, pointStyle2)
        ]
        self.chart.update()
      )
    )
  return self

@ReportChart = (loading_id, chart_id, stacked_id, pointStyle='circle') ->
  self = this

  if stacked_id
    $(stacked_id).change((event) ->
      self.redraw(this.checked)
    )
    self.chart = chart($(chart_id + ' canvas'), $(stacked_id).get(0).checked)
  else
    self.chart = chart($(chart_id + ' canvas'), false)

  self.redraw = (stacked) ->
    redraw(self.chart, stacked)
  
  self.updateData = (url) ->
    fill = if stacked_id
      $(stacked_id).get(0).checked
    else
      false
    $(chart_id).hide()
    $(loading_id).show()
    with_data(url, (data) ->
      data = consolidate(data)
      $(loading_id).hide()
      $(chart_id).show()
      self.chart.data.labels = $.map(data, (datum) -> new Date(datum.created_at))
      self.chart.data.datasets = [
        datasetConfig('Confirmed', $.map(data, (datum) -> datum.confirmed || NaN), 'rgba(255, 0, 0, 1)', fill, pointStyle),
        datasetConfig('Deaths',    $.map(data, (datum) -> datum.deaths || NaN),    'rgba(0, 0, 0, 1)',   fill, pointStyle)
      ]
      self.chart.update()
    )
  return self
