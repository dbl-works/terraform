const fivetran = require('./utils/fivetran');
const cloudwatch = require('./utils/cloudwatch');

exports.handler = async (request, context, callback) => {
  try {
    // TODO: next if computed end time is before the prevCursor
    const performanceTransactionRows = await cloudwatch.getPerformanceMetrics()
    const errorCountTransactionRows = await cloudwatch.getErrorCountMetrics()
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
