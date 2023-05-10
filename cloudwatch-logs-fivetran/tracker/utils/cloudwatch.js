const AWS = require('aws-sdk')
const dateUtil = require('./date');

const recordRows = ({ dataPoints, params }) => {
  return dataPoints.map(data => {
    const queryParam = params.MetricDataQueries.find((param) =>
      param.Id === data.Id
    )

    const [projectName, environment] = queryParam.Id.split("_").slice(-2)
    const unit = queryParam?.MetricStat.Unit

    const metricStat = queryParam?.MetricStat

    return {
      start_time: params.StartTime.toISOString(),
      end_time: params.EndTime.toISOString(),
      project_name: projectName,
      environment: environment,
      region: constants.AWS_REGION,
      metric_name: metricStat?.Metric?.MetricName,
      value: metricStat?.Stat,
      created_at: new Date().toISOString()
    }
  })
}

const getCloudwatchData = async () => {
  const prevHour = dateUtil.previousHour()

  var cloudwatchlogs = new AWS.CloudWatchLogs(); // https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/FilterAndPatternSyntax.html

  // var params = {
  //   endTime: 'NUMBER_VALUE',
  //   filterPattern: 'STRING_VALUE',
  //   interleaved: true || false,
  //   limit: 'NUMBER_VALUE',
  //   logGroupIdentifier: 'STRING_VALUE',
  //   logGroupName: 'STRING_VALUE',
  //   logStreamNamePrefix: 'STRING_VALUE',
  //   logStreamNames: [
  //     'STRING_VALUE',
  //   ],
  //   nextToken: 'STRING_VALUE',
  //   startTime: 'NUMBER_VALUE',
  //   unmask: true || false
  // };
  const params = {
    startTime: dateUtil.startTime(),
    endTime: dateUtil.endTime(),
    filterPattern: process.env.FILTER_PATTERN || '',
    logGroupName: process.env.LOG_GROUP_NAME ,
  }

  const rows = cloudwatchlogs.filterLogEvents(params, function(err, data) {
    if (err) {
      console.log(err, err.stack)

      return recordRows(data, params)
    } else {
      console.log(data)
    }
  })

  return rows
}
