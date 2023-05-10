const AWS = require('aws-sdk')
const dateUtil = require('./date');

const recordRows = ({ dataPoints, params }) => {
  return dataPoints.map(data => {
    // TODO: Extract the json here and generate multiple data point based on the json string
    console.log(data)
    return {
      start_time: params.startTime.toISOString(),
      end_time: params.endTime.toISOString(),
      project_name: process.env.PROJECT, // GET this from the log stream name
      environment: process.env.ENVIRONMENT,
      region: constants.AWS_REGION,
      metric_name: 'default-metric',
      value: 'fake-value',
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
