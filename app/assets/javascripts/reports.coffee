# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
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

changeIn = (data, field) ->
  lastField = 0
  results = []
  data.forEach((datum) ->
    if datum[field]
      if lastField
        results.push(datum[field] - lastField)
      else
        results.push(datum[field])
      lastField = datum[field]
    else
      results.push(NaN)
  )
  results

with_data = (url, handler) ->
  $.ajax({
    url: url,
    dataType: 'json',
    success: (data, textStatus, jqXHR) ->
      handler(data)
    error: (jqXHR, textStatus, errorThrown) ->
      console.log(jqXHR, textStatus, errorThrown)
  })

redraw = (chart, stacked, confirmed, deaths, datasetConfigs) ->
  chart.data.datasets = []
  datasetConfigs.forEach((dsc) ->
    if dsc.includeWhen(stacked, confirmed, deaths)
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

DatasetConfigLine = (label, data, color, fill, pointStyle) ->
  self = this
  self.label = label
  self.data = data
  self.type = 'line'
  self.borderWidth = 1
  self.cubicInterpolationMode = 'monotone'
  self.backgroundColor = color
  self.borderColor = color
  self.fill = fill
  self.pointStyle = pointStyle
  self.includeWhen = (stacked, confirmed, deaths) ->
    if stacked
      true
    else
      if confirmed && self.label.includes('Confirmed')
        true
      else if deaths && self.label.includes('Deaths')
        true
      else
        false
  self

DatasetConfigBar = (label, data, color) ->
  self = this
  self.label = label
  self.data = data
  self.type = 'bar'
  self.backgroundColor = color
  self.borderColor = color
  self.includeWhen = (stacked, confirmed, deaths) ->
    if stacked
      false
    else
      if confirmed && self.label.includes('Confirmed')
        true
      else if deaths && self.label.includes('Deaths')
        true
      else
        false
  self

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
  self.super = ReportChart(chart_id, pointStyle1)

  self.updateData = (label1, url1, label2, url2) ->
    self.super.canvas_element.hide()
    self.super.loading_element.show()
    with_data(url1, (data1) ->
      with_data(url2, (data2) ->
        data1 = consolidate(data1)
        data2 = consolidate(data2)
        data = merge(data1, data2)
        self.super.canvas_element.show()
        self.super.loading_element.hide()
        self.super.chart.data.labels = $.map(data, (datum) -> new Date(datum.created_at))
        self.super.datasetConfigs = [
          new DatasetConfigLine(label1 + ' Confirmed', $.map(data, (datum) -> datum.confirmed1 || NaN), 'rgba(255, 0, 0, 1)', self.super.stacked(), pointStyle1),
          new DatasetConfigLine(label1 + ' Deaths',    $.map(data, (datum) -> datum.deaths1 || NaN),    'rgba(0, 0, 0, 1)',   self.super.stacked(), pointStyle1),
          new DatasetConfigLine(label2 + ' Confirmed', $.map(data, (datum) -> datum.confirmed2 || NaN), 'rgba(255, 0, 0, 1)', self.super.stacked(), pointStyle2),
          new DatasetConfigLine(label2 + ' Deaths',    $.map(data, (datum) -> datum.deaths2 || NaN),    'rgba(0, 0, 0, 1)',   self.super.stacked(), pointStyle2)
        ]
        self.super.redraw()
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
        new DatasetConfigLine(
          'Confirmed', 
          $.map(data, (datum) -> datum['confirmed'] || NaN), 
          'rgba(255, 0, 0, 1)', 
          self.stacked(), 
          pointStyle
        ),
        new DatasetConfigLine(
          'Deaths',
          $.map(data, (datum) -> datum['deaths'] || NaN),
          'rgba(0, 0, 0, 1)',
          self.stacked(), 
          pointStyle
        )
      ]
      if self.stacked()
      else
        self.datasetConfigs = self.datasetConfigs.concat([
          new DatasetConfigBar(
            'Change in Confirmed',
            changeIn(data, 'confirmed'),
            'rgba(255, 0, 0, 0.5)', 
          ),
          new DatasetConfigBar(
            'Change in Deaths',
            changeIn(data, 'deaths'),
            'rgba(0, 0, 1, 0.5)', 
          )
        ])
      self.redraw()
    )
  return self

@ReportUSMap = (map_id, chart_id, pointStyle='circle') ->
  self = this
  self.super = ReportChart(chart_id, pointStyle)
  self.super.loading_element.hide()
  
  self.handler = (data) ->
    $('#state-name').text(data[0].state)
    self.super.loading_element.hide()
    self.super.canvas_element.show()
    self.super.chart.data.labels = $.map(data, (datum) -> new Date(datum.created_at))
    self.datasetConfigs = [
      new DatasetConfigLine(
        'Confirmed', 
        $.map(data, (datum) -> datum['cases'] || NaN), 
        'rgba(255, 0, 0, 1)', 
        self.super.stacked(), 
        pointStyle
      ),
      new DatasetConfigLine(
        'Deaths', 
        $.map(data, (datum) -> datum['deaths'] || NaN),
        'rgba(0, 0, 0, 1)', 
        self.super.stacked(), 
        pointStyle
      ),
    ]
    if self.super.stacked()
    else
      self.datasetConfigs = self.datasetConfigs.concat([
        new DatasetConfigBar(
          'Change in Confirmed',
          changeIn(data, 'cases'),
          'rgba(255, 0, 0, 0.5)', 
        ),
        new DatasetConfigBar(
          'Change in Deaths',
          changeIn(data, 'deaths'),
          'rgba(0, 0, 1, 0.5)', 
        )
      ])
    self.redraw()
    
  $(map_id).usmap({
    click: (event, data) ->
      self.super.loading_element.show()
      $.ajax({
        url: '/us_reports/state/' + data.name,
        dataType: 'json',
        success: (data, textStatus, jqXHR) ->
          self.handler(data)
        error: (jqXHR, textStatus, errorThrown) ->
          console.log(jqXHR, textStatus, errorThrown)
      })
    stateHoverStyles: { fill: '#11c'}
  });
  
  return self