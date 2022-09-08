const AWS = require('aws-sdk')
const constants = require('./../constants');
const dateUtil = require('./date');

const cloudwatch = new AWS.CloudWatch()

const ECS_METRICS = [
  'CPUUtilization',
  'MemoryUtilization'
]
const PERCENTILES = [
  'p99',
  'p90',
  'p50'
]

const formatQueryId = (name) => {
  return name.replace(/-|\//g, '_')
}

const ecsMetricQueries = ({ serviceName, clusterName, projectName }) => {
  return ECS_METRICS.map(metric => ({
    Id: `${metric.toLowerCase()}_${formatQueryId(clusterName)}_${projectName}`, /* /^[a-z][a-zA-Z0-9_]*$./ */
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

const responseTimesQueries = ({ projectName, loadBalancerName }) => {
  return PERCENTILES.map(percentile => ({
    Id: `${percentile}_${formatQueryId(loadBalancerName)}_${projectName}`, /* /^[a-z][a-zA-Z0-9_]*$./ */
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

const errorCountsQueries = ({ projectName, loadBalancerName }) => {
  return {
    Id: `errorCount_${formatQueryId(loadBalancerName)}_${projectName}`, // /^[a-z][a-zA-Z0-9_]*$./
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

const performanceMetricQueries = ({ serviceName, clusterName, projectName, loadBalancerName }) => {
  return [
    ...ecsMetricQueries({ serviceName, clusterName, projectName }),
    ...responseTimesQueries({ projectName, loadBalancerName }),
    errorCountsQueries({ projectName, loadBalancerName })
  ]
}

const formatTransactionRows = ({ dataPoints, params }) => {
  return dataPoints.map(data => {
    const queryParam = params.MetricDataQueries.find((param) =>
      param.Id === data.Id
    )

    const projectName = queryParam.Id.split("_").slice(-1)[0]
    const unit = queryParam?.MetricStat.Unit

    const metricStat = queryParam?.MetricStat

    return {
      project_name: projectName,
      region: constants.AWS_REGION,
      metric_name: metricStat?.Metric?.MetricName,
      dimensions: metricStat?.Metric?.Dimensions,
      start_time: params.StartTime.toISOString(),
      end_time: params.EndTime.toISOString(),
      stat: metricStat?.Stat,
      value: data.Values[0] || (unit === 'Count' ? 0 : "Null"),
      unit,
      created_at: new Date().toISOString()
    }
  })
}
const getCloudwatchData = async () => {
  const resourcesData = JSON.parse(constants.RESOURCES_DATA)
  const metricDataQueries = resourcesData.flatMap((data) => performanceMetricQueries(data))

  const prevHour = dateUtil.previousHour()
  const params = {
    MetricDataQueries: metricDataQueries,
    StartTime: dateUtil.oneHourBefore(prevHour),
    EndTime: prevHour
  }

  // NOTE: A single GetMetricData call can include as many as 500 MetricDataQuery structures.
  // NOTE: We can't retrieve data from region different than the lambda region
  const { MetricDataResults: ecsDataPoints } = await cloudwatch.getMetricData(params).promise()
  // Sample API Response
  // {
  //   ResponseMetadata: { RequestId: 'fe077633-9093-47e7-8e64-d26c244494bb' },
  //   MetricDataResults: [
  //     {
  //       Id: 'cpu_utilization',
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

module.exports = {
  getCloudwatchData
}
