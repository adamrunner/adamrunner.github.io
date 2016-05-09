---
---
# Doc Ready
$ ->
  drawChart()
  $('#go').click drawChart

Highcharts.setOptions(
  global:
    useUTC: false
  plotOptions:
    line:
      marker:
        enabled: false
)

$("#from").val(moment().format('YYYY-MM-DD'))
$("#to").val(moment().add(1, 'days').format('YYYY-MM-DD'))

$('#yesterday').click (event) ->
  $("#from").val(moment().subtract(1, 'days').format('YYYY-MM-DD'))
  $("#to").val(moment().format('YYYY-MM-DD'))
  drawChart()

$('#today').click (event) ->
  $("#from").val(moment().format('YYYY-MM-DD'))
  $("#to").val(moment().add(1, 'days').format('YYYY-MM-DD'))
  drawChart()
$('#minus-one-day').click (event) ->
  backDate = moment($("#from").val()).subtract(1, 'days').format('YYYY-MM-DD')
  $("#from").val(backDate)
  $("#to").val(moment(backDate).add(1, 'days').format('YYYY-MM-DD'))
  drawChart()
$('#add-one-day').click (event) ->
  addDate = moment($("#from").val()).add(1, 'days').format('YYYY-MM-DD')
  $("#from").val(addDate)
  $("#to").val(moment(addDate).add(1, 'days').format('YYYY-MM-DD'))
  drawChart()

window.client = new $.es.Client(
  host: [
    'https://es.adamrunner.com'
  ]
  log: 'trace'
  )
window.search_query =
  'index': 'temperature'
  'body':
    'sort':
      'timestamp' : 'asc'
    'query':
      'bool':
        'must':
          'match_all': {}
          'filter':
            'range':
              'timestamp': {}


drawChart = ->
  window.search_query['size'] = parseInt($("#per_page").val())
  from    = moment($('#from').val()).format()
  to      = moment($('#to').val()).format()
  timestamp = window.search_query['body']['query']['bool']['must']['filter']['range']['timestamp']
  timestamp['lte'] = to if to
  timestamp['gte'] = from if from
  results = client.search(window.search_query)
  results.then (results) ->
    $("#result-text ul").html("<li>Total Results: #{results.hits.total} </li><li>Displayed Results: #{results.hits.hits.length} </li>")
    window.outside_data = results.hits.hits.map (o) ->
      [moment(o._source.timestamp).valueOf(), o._source.outside_temp ]
    window.inside_data = results.hits.hits.map (o) ->
      [moment(o._source.timestamp).valueOf(), parseFloat(o._source.indoor_temp) ]
    window.kitchen_data = results.hits.hits.map (o) ->
      kitchen_temp = parseFloat(o._source.kitchen_temp)
      return null if isNaN(kitchen_temp)
      [moment(o._source.timestamp).valueOf(), kitchen_temp]
    window.kitchen_data = kitchen_data.filter(Boolean)
    # debugger
    $('#container').highcharts(
      title: text: 'Temperature over Time'
      yAxis:
        title: text :'Temperature'
      xAxis:
        type: 'datetime'
        # maxZoom: 24
        title: text: 'Date'
      series: [{
        name: 'Outdoor °F'
        data: outside_data
        },
        {
          name: 'Indoor °F'
          data: inside_data
        },
        name: 'Kitchen °F'
        data: kitchen_data
      ]
    )
