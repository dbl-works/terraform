const AWS = require('aws-sdk')
const cloudwatch = new AWS.CloudWatch()
const dateUtil = require('./utils/date');
const fivetran = require('./utils/fivetran');
const constants = require('./constants');

const ECS_METRICS = [
  'CPUUtilization',
  'MemoryUtilization'
]

const PERCENTILES = [
  'p99',
  'p90',
  'p50'
]

function formatTransactionRows ({ dataPoints, params }) {
  return dataPoints.map(data => {
    const queryParam = params.MetricDataQueries.find((param) =>
      param.Id === data.Id
    )

    const [_metric, projectName] = queryParam.Id.split("_")
    const unit = queryParam?.MetricStat.Unit

    return {
      project_name: projectName,
      region: constants.AWS_REGION,
      metric_name: queryParam?.MetricStat?.Metric?.MetricName,
      dimensions: queryParam?.MetricStat?.Metric?.Dimensions,
      start_time: params.StartTime.toISOString(),
      end_time: params.EndTime.toISOString(),
      stat: queryParam?.MetricStat?.Stat,
      value: data.Values[0] || (unit === 'Count' ? 0 : "Null"),
      unit,
      created_at: new Date().toISOString()
    }
  })
}

function setupErrorCountsQueries ({ projectName, loadBalancerName }) {
  return {
    Id: `errorCount_${projectName}`, // /^[a-z][a-zA-Z0-9_]*$./
    MetricStat: {
      Metric: {
        Dimensions: [
          {
            Name: 'LoadBalancer',
            Value: loadBalancerName
          },
        ],
        MetricName: 'HTTPCode_Target_5XX_Count', /* required */
        Namespace: 'AWS/ApplicationELB', /* required */
      },
      Period: 86400,
      Stat: 'Sum', /* required */
      Unit: 'Count'
    },
    ReturnData: true
  }
}

function setupResponseTimesQueries ({ projectName, loadBalancerName }) {
  return PERCENTILES.map(percentile => ({
    // TODO: Have to be more specific
    Id: `${percentile.toLowerCase()}_${projectName}`, // /^[a-z][a-zA-Z0-9_]*$./
    MetricStat: {
      Metric: {
        Dimensions: [
          {
            Name: 'LoadBalancer',
            Value: loadBalancerName
          },
        ],
        MetricName: 'TargetResponseTime', /* required */
        Namespace: 'AWS/ApplicationELB', /* required */
      },
      Period: constants.PERIOD,
      Stat: percentile, /* required */
      Unit: 'Seconds' // If we set it as Milliseconds, the value returned will be undefined
    },
    ReturnData: true
  }))
}

function setupECSMetricQueries ({ serviceName, clusterName, projectName }) {
  return ECS_METRICS.map(metric => ({
    Id: `${metric.toLowerCase()}_${projectName}`, /* required */
    MetricStat: {
      Metric: {
        Dimensions: [
          {
            Name: 'ServiceName',
            Value: serviceName
          },
          {
            Name: 'ClusterName',
            Value: clusterName
          }
        ],
        MetricName: metric, /* required */
        Namespace: 'AWS/ECS', /* required */
      },
      Period: constants.PERIOD,
      Stat: 'Maximum', /* required */
      Unit: 'Percent'
    },
    ReturnData: true
  }))
}

function setupPerformanceMetricQueries (data) {
  return [
    ...setupECSMetricQueries(data),
    ...setupResponseTimesQueries(data)
  ]
}

function setupMetricParams (metricDataQueries) {
  const prevHour = dateUtil.previousHour()

  return {
    MetricDataQueries: metricDataQueries,
    StartTime: dateUtil.oneHourBefore(prevHour),
    EndTime: prevHour
  }
}

// TODO: Think of how to make sure the lambda does not retrieve the same data twice
// (last record endtime -> prevCursor) -> (new record endtime -> current Cursor)

async function getPerformanceMetrics () {
  const resourcesData = JSON.parse(constants.RESOURCES_DATA)
  const metricDataQueries = resourcesData.flatMap((data) => setupPerformanceMetricQueries(data))
  const params = setupMetricParams(metricDataQueries)
  // NOTE: A single GetMetricData call can include as many as 500 MetricDataQuery structures.
  // NOTE: We can't retrieve data from region different than the lambda region
  const { MetricDataResults: ecsDataPoints } = await cloudwatch.getMetricData(params).promise()
  // TODO: Have another call one for the sum of one day 500 error count, period = 1 day at the end of day
  // TODO: one day based on eu central time?

  // Sample Response
  // {
  //   ResponseMetadata: { RequestId: 'fe077633-9093-47e7-8e64-d26c244494bb' },
  //   MetricDataResults: [
  //     {
  //       Id: 'cpu',
  //       Label: 'CPUUtilization',
  //       Timestamps: [ 2022-09-07T15:00:00.000Z ],
  //       Values: [ 21.19099235534668 ],
  //       StatusCode: 'Complete',
  //       Messages: []
  //     }
  //   ],
  //   Messages: []
  // }
  return formatTransactionRows({ dataPoints: ecsDataPoints, params })
}

async function getErrorCountMetrics () {
  const resourcesData = JSON.parse(constants.RESOURCES_DATA)
  const metricDataQueries = resourcesData.flatMap((data) => setupErrorCountsQueries(data))

  const startTime = dateUtil.startOfTheDay(dateUtil.previousDay(new Date))
  const endTime = dateUtil.endOfTheDay(dateUtil.previousDay(new Date))

  const params = {
    MetricDataQueries: metricDataQueries,
    StartTime: startTime,
    EndTime: endTime
  }

  const { MetricDataResults: dataPoints } = await cloudwatch.getMetricData(params).promise()

  return formatTransactionRows({ dataPoints, params })
}

exports.handler = async (request, context, callback) => {
  try {

    // TODO: next if computed end time is after the prevCursor
    const performanceTransactionRows = await getPerformanceMetrics()
    // TODO: Only run this at the midnight
    const errorCountTransactionRows = await getErrorCountMetrics()
    const newTransactions = [...performanceTransactionRows, ...errorCountTransactionRows]
    console.log('records!', newTransactions)

    return fivetran.setupFivetranResponse({
      state: request.state,
      newTransactions: []
    })

  } catch (error) {
    // TODO: Include Sentry here
    console.log('error', error)
  }
}
