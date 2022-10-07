const fivetran = require('./utils/fivetran');
const cloudwatch = require('./utils/cloudwatch');

exports.handler = async (request, _context, _callback) => {
  const newRecords = await cloudwatch.getCloudwatchData()

  return fivetran.setupFivetranResponse({
    state: request.state,
    newRecords
  })
}
