const AWS = require('aws-sdk')
const PERIOD = process.env.PERIOD

// 500 error
// ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", name, { "label" : "5xx Count" }],
// Sum per 86400s

function previousHour () {
  const today = new Date()
  const hour = today.getHours()
  today.setHours(hour - 1)
  today.setMinutes(0)
  today.setSeconds(0)
  return today
}

function oneHourBefore (date) {
  const currentTime = date.getTime()
  return new Date(currentTime - 1 * 60 * 60 * 1000)
}

const ECS_METRICS = [
  'CPUUtilization',
  'MemoryUtilization'
]

const PERCENTILES = [
  'p99',
  'p90',
  'p50'
]

function setupResponseTimesQueries ({ projectName, loadBalancerName }) {
  return PERCENTILES.map(percentile => ({
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
      Period: PERIOD,
      Stat: 'Maximum', /* required */
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
      Period: PERIOD,
      Stat: 'Maximum', /* required */
      Unit: 'Percent'
    },
    ReturnData: true
  }))
}

function setupMetricQueries (data) {
  return [
    ...setupECSMetricQueries(data),
    ...setupResponseTimesQueries(data)
  ]
}

function setupMetricParams (metricDataQueries) {
  const prevHour = previousHour()

  return {
    MetricDataQueries: metricDataQueries,
    StartTime: oneHourBefore(prevHour),
    EndTime: prevHour
  }
}

// TODO: Think of how to make sure the lambda does not retrieve the same data twice
// (last record endtime -> prevCursor) -> (new record endtime -> current Cursor)

exports.handler = async (request, context, callback) => {
  const cloudwatch = new AWS.CloudWatch()
  try {

    // TODO: next if computed end time is after the prevCursor
    const resourcesData = JSON.parse(process.env.RESOURCES_DATA)

    const metricDataQueries = resourcesData.flatMap((data) => setupMetricQueries(data))
    const params = setupMetricParams(metricDataQueries)
    // NOTE: A single GetMetricData call can include as many as 500 MetricDataQuery structures.
    // NOTE: We can't retrieve data from region different than the lambda region
    const { MetricDataResults: dataPoints } = await cloudwatch.getMetricData(params).promise()
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
    const newRecords = dataPoints.map(data => {
      const queryParam = params.MetricDataQueries.find((param) =>
        param.Id === data.Id
      )

      const [_metric, projectName] = queryParam.Id.split("_")

      return {
        project_name: projectName,
        region: process.env.AWS_REGION,
        metric_name: queryParam?.MetricStat?.Metric?.MetricName,
        dimensions: queryParam?.MetricStat?.Metric?.Dimensions,
        start_time: params.StartTime.toISOString(),
        end_time: params.EndTime.toISOString(),
        stat: queryParam?.MetricStat?.Stat,
        value: data.Values[0] || "Null",
        unit: queryParam?.MetricStat.Unit,
        created_at: new Date().toISOString()
      }
    })

    console.log('records!', newRecords)

    return {
      state: {
        cursor: new Date().toISOString(),
      },
      insert: {
        transaction: [], // TODO: Pssing newRecords here
      },
      delete: {
        transaction: [],
      },
      schema: {
        transaction: {
          // TODO: cannot use metric name because it is not specific for p99
          // TODO: is this expensive to have multiple primary key
          primary_key: ['end_time', 'project_name', 'metric_name', 'region']
        },
      },
      hasMore: false
    }
  } catch (error) {
    // TODO: Include Sentry here
    console.log('error', error)
  }
}
