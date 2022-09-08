const AWS = require('aws-sdk')
const cloudwatch = new AWS.CloudWatch()
const dateUtil = require('./utils/date');
const fivetran = require('./utils/fivetran');
const cloud = require('./utils/cloudwatch');
const constants = require('./constants');

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

function setupMetricParams (metricDataQueries) {
  const prevHour = dateUtil.previousHour()

  return {
    MetricDataQueries: metricDataQueries,
    StartTime: dateUtil.oneHourBefore(prevHour),
    EndTime: prevHour
  }
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
    const performanceTransactionRows = await cloud.getPerformanceMetrics()
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
