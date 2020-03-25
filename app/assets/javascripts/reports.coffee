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

redraw = (chart, stacked, confirmed, deaths, datasetConfigs) ->
  chart.data.datasets = []
  if confirmed
    datasetConfigs.forEach((dsc) ->
      if dsc.label.includes('Confirmed')
        chart.data.datasets.push(dsc)
    )
  if deaths
    datasetConfigs.forEach((dsc) ->
      if dsc.label.includes('Deaths')
        chart.data.datasets.push(dsc)
    )
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
  merged

@ReportChart2 = (chart_id, pointStyle1, pointStyle2) ->
  self = this
  
  self.loading_element = $(chart_id + ' .loading')

  self.canvas_element = $(chart_id + ' canvas')
  self.stacked_element = $('#stacked-switch')
  self.stacked = () ->
    if self.stacked_element.length != 0
      self.stacked_element.get(0).checked
    else
      false
  self.confirmed_element = $('#confirmed')
  self.confirmed = () ->
    if self.confirmed_element.length != 0
      self.confirmed_element.get(0).checked
    else
      true
  self.deaths_element = $('#deaths')
  self.deaths = () ->
    if self.deaths_element.length != 0
      self.deaths_element.get(0).checked
    else
      true
  
  self.stacked_element.change((event) ->
    self.redraw()
  )
  self.confirmed_element.change((event) ->
    self.redraw()
  )
  self.deaths_element.change((event) ->
    self.redraw()
  )

  self.chart = new Chart(self.canvas_element.get(0).getContext('2d'), {
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
          }
        }]
      }
    }
  })

  self.redraw = () ->
    redraw(self.chart, self.stacked(), self.confirmed(), self.deaths(), self.datasetConfigs)
  
  self.updateData = (label1, url1, label2, url2) ->
    self.canvas_element.hide()
    self.loading_element.show()
    with_data(url1, (data1) ->
      with_data(url2, (data2) ->
        data1 = consolidate(data1)
        data2 = consolidate(data2)
        data = merge(data1, data2)
        self.canvas_element.show()
        self.loading_element.hide()
        self.chart.data.labels = $.map(data, (datum) -> new Date(datum.created_at))
        self.datasetConfigs = [
          datasetConfig(label1 + ' Confirmed', $.map(data, (datum) -> datum.confirmed1 || NaN), 'rgba(255, 0, 0, 1)', self.stacked(), pointStyle1),
          datasetConfig(label1 + ' Deaths',    $.map(data, (datum) -> datum.deaths1 || NaN),    'rgba(0, 0, 0, 1)',   self.stacked(), pointStyle1),
          datasetConfig(label2 + ' Confirmed', $.map(data, (datum) -> datum.confirmed2 || NaN), 'rgba(255, 0, 0, 1)', self.stacked(), pointStyle2),
          datasetConfig(label2 + ' Deaths',    $.map(data, (datum) -> datum.deaths2 || NaN),    'rgba(0, 0, 0, 1)',   self.stacked(), pointStyle2)
        ]
        self.redraw()
      )
    )
  return self

@ReportChart = (chart_id, pointStyle='circle') ->
  self = this

  self.loading_element = $(chart_id + ' .loading')
  self.canvas_element = $(chart_id + ' canvas')
  self.stacked_element = $('#stacked-switch')
  self.stacked = () ->
    if self.stacked_element.length != 0
      self.stacked_element.get(0).checked
    else
      false
  self.confirmed_element = $('#confirmed')
  self.confirmed = () ->
    if self.confirmed_element.length != 0
      self.confirmed_element.get(0).checked
    else
      true
  self.deaths_element = $('#deaths')
  self.deaths = () ->
    if self.deaths_element.length != 0
      self.deaths_element.get(0).checked
    else
      true
  
  self.stacked_element.change((event) ->
    self.redraw()
  )
  self.confirmed_element.change((event) ->
    self.redraw()
  )
  self.deaths_element.change((event) ->
    self.redraw()
  )

  self.chart = new Chart(self.canvas_element.get(0).getContext('2d'), {
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
          }
        }]
      }
    }
  })

  self.redraw = () ->
    redraw(self.chart, self.stacked(), self.confirmed(), self.deaths(), self.datasetConfigs)
  
  self.updateData = (url) ->
    self.canvas_element.hide()
    self.loading_element.show()
    with_data(url, (data) ->
      data = consolidate(data)
      self.loading_element.hide()
      self.canvas_element.show()
      self.chart.data.labels = $.map(data, (datum) -> new Date(datum.created_at))
      self.datasetConfigs = [
        datasetConfig('Confirmed', $.map(data, (datum) -> datum['confirmed'] || NaN), 'rgba(255, 0, 0, 1)', self.stacked(), pointStyle)
        datasetConfig('Deaths', $.map(data, (datum) -> datum['deaths'] || NaN), 'rgba(0, 0, 0, 1)', self.stacked(), pointStyle)
      ]
      self.redraw()
    )
  return self
