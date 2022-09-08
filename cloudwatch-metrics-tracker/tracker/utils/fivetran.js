const setupFivetranResponse = ({ state, newTransactions = [], deletedTransactions = [] }) => {
  return {
    state: {
      ...state,
      cursor: new Date().toISOString(),
    },
    insert: {
      transaction: newTransactions,
    },
    delete: {
      transaction: deletedTransactions,
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
}

module.exports = {
  setupFivetranResponse
}
