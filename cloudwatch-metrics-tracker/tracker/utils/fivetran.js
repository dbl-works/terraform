const setupFivetranResponse = ({ state, newRecords = [], deletedRecords = [] }) => {
  return {
    state: {
      ...state,
      cursor: new Date().toISOString(),
    },
    insert: {
      metric: newRecords,
    },
    delete: {
      metric: deletedRecords,
    },
    schema: {
      metric: {
        primary_key: [
          'end_time',
          'metric_name',
          'project_name',
          'region',
          'stat'
        ]
      },
    },
    hasMore: false
  }
}

module.exports = {
  setupFivetranResponse
}
