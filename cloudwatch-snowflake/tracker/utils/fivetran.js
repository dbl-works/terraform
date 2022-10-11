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
          'start_time',
          'end_time',
          'metric_name',
          'project_name',
          'region',
          'stat',
          'environment'
        ]
      },
    },
    hasMore: false
  }
}

module.exports = {
  setupFivetranResponse
}
