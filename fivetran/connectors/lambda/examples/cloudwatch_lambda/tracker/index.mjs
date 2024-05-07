import {
  CloudWatchClient,
  GetMetricDataCommand,
} from "@aws-sdk/client-cloudwatch";

const PERIOD = process.env.PERIOD;
const RESOURCES_DATA = process.env.RESOURCES_DATA;
const AWS_REGION = process.env.AWS_REGION;

const previousHour = () => {
  const today = new Date();
  const lastHour = today.getHours() - 1;
  today.setUTCHours(lastHour, 0, 0, 0);
  return today;
};

const oneHourBefore = (time) => {
  const currentTime = time.getTime();
  return new Date(currentTime - 1 * 60 * 60 * 1000);
};

const setupFivetranResponse = ({
  state,
  newRecords = [],
  deletedRecords = [],
}) => {
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
          "start_time",
          "end_time",
          "metric_name",
          "project_name",
          "region",
          "stat",
          "environment",
        ],
      },
    },
    hasMore: false,
  };
};

const ECS_METRICS = ["CPUUtilization", "MemoryUtilization"];
const PERCENTILES = ["Maximum", "p99.9", "p99"];

// expected pattern: ^[a-z][a-zA-Z0-9_]*$
const formatQueryId = (name) => {
  return name.replace(/-|\/|\./g, "_").toLowerCase();
};

const ecsMetricQueries = ({
  serviceName,
  clusterName,
  projectName,
  environment,
}) => {
  return ECS_METRICS.map((metric) => ({
    Id: `${metric.toLowerCase()}_${formatQueryId(
      clusterName
    )}_${projectName}_${environment}` /* /^[a-z][a-zA-Z0-9_]*$./ */,
    MetricStat: {
      Metric: {
        Dimensions: [
          {
            Name: "ServiceName",
            Value: serviceName,
          },
          {
            Name: "ClusterName",
            Value: clusterName,
          },
        ],
        MetricName: metric /* required */,
        Namespace: "AWS/ECS" /* required */,
      },
      Period: PERIOD,
      Stat: "Maximum" /* required */,
      Unit: "Percent",
    },
    ReturnData: true,
  }));
};

const responseTimesQueries = ({
  projectName,
  loadBalancerName,
  environment,
}) => {
  return PERCENTILES.map((percentile) => ({
    Id: `${formatQueryId(percentile)}_${formatQueryId(
      loadBalancerName
    )}_${projectName}_${environment}` /* /^[a-z][a-zA-Z0-9_]*$./ */,
    MetricStat: {
      Metric: {
        Dimensions: [
          {
            Name: "LoadBalancer",
            Value: loadBalancerName,
          },
        ],
        MetricName: "TargetResponseTime" /* required */,
        Namespace: "AWS/ApplicationELB" /* required */,
      },
      Period: PERIOD,
      Stat: percentile /* required */,
      Unit: "Seconds", // If we set it as Milliseconds, the value returned will be undefined
    },
    ReturnData: true,
  }));
};

const errorCountsQueries = ({ projectName, loadBalancerName, environment }) => {
  return {
    Id: `errorCount_${formatQueryId(
      loadBalancerName
    )}_${projectName}_${environment}`, // /^[a-z][a-zA-Z0-9_]*$./
    MetricStat: {
      Metric: {
        Dimensions: [
          {
            Name: "LoadBalancer",
            Value: loadBalancerName,
          },
        ],
        MetricName: "HTTPCode_Target_5XX_Count" /* required */,
        Namespace: "AWS/ApplicationELB" /* required */,
      },
      Period: PERIOD,
      Stat: "Sum" /* required */,
      Unit: "Count",
    },
    ReturnData: true,
  };
};

const clientErrorCountsQueries = ({
  projectName,
  loadBalancerName,
  environment,
}) => {
  return {
    Id: `clientErrorCount_${formatQueryId(
      loadBalancerName
    )}_${projectName}_${environment}`, // /^[a-z][a-zA-Z0-9_]*$./
    MetricStat: {
      Metric: {
        Dimensions: [
          {
            Name: "LoadBalancer",
            Value: loadBalancerName,
          },
        ],
        MetricName: "HTTPCode_Target_4XX_Count" /* required */,
        Namespace: "AWS/ApplicationELB" /* required */,
      },
      Period: PERIOD,
      Stat: "Sum" /* required */,
      Unit: "Count",
    },
    ReturnData: true,
  };
};

const successCountsQueries = ({
  projectName,
  loadBalancerName,
  environment,
}) => {
  return {
    Id: `successCount_${formatQueryId(
      loadBalancerName
    )}_${projectName}_${environment}`, // /^[a-z][a-zA-Z0-9_]*$./
    MetricStat: {
      Metric: {
        Dimensions: [
          {
            Name: "LoadBalancer",
            Value: loadBalancerName,
          },
        ],
        MetricName: "HTTPCode_Target_2XX_Count" /* required */,
        Namespace: "AWS/ApplicationELB" /* required */,
      },
      Period: PERIOD,
      Stat: "Sum" /* required */,
      Unit: "Count",
    },
    ReturnData: true,
  };
};

const performanceMetricQueries = ({
  serviceName,
  clusterName,
  projectName,
  loadBalancerName,
  environment,
}) => {
  return [
    ...ecsMetricQueries({ serviceName, clusterName, projectName, environment }),
    ...responseTimesQueries({ projectName, loadBalancerName, environment }),
    errorCountsQueries({ projectName, loadBalancerName, environment }),
    clientErrorCountsQueries({ projectName, loadBalancerName, environment }),
    successCountsQueries({ projectName, loadBalancerName, environment }),
  ];
};

const recordRows = ({ dataPoints, params }) => {
  return dataPoints.map((data) => {
    const queryParam = params.MetricDataQueries.find(
      (param) => param.Id === data.Id
    );

    const [projectName, environment] = queryParam.Id.split("_").slice(-2);
    const unit = queryParam?.MetricStat.Unit;

    const metricStat = queryParam?.MetricStat;

    return {
      project_name: projectName,
      environment: environment,
      region: AWS_REGION,
      metric_name: metricStat?.Metric?.MetricName,
      dimensions: metricStat?.Metric?.Dimensions,
      start_time: params.StartTime.toISOString(),
      end_time: params.EndTime.toISOString(),
      stat: metricStat?.Stat,
      value: data.Values[0] || (unit === "Count" ? 0 : "Null"),
      unit,
      created_at: new Date().toISOString(),
    };
  });
};
const getCloudwatchData = async () => {
  const resourcesData = JSON.parse(RESOURCES_DATA);
  const metricDataQueries = resourcesData.flatMap((data) =>
    performanceMetricQueries(data)
  );

  const prevHour = previousHour();
  const params = {
    MetricDataQueries: metricDataQueries,
    StartTime: oneHourBefore(prevHour),
    EndTime: prevHour,
  };

  // NOTE: A single GetMetricData call can include as many as 500 MetricDataQuery structures.
  // NOTE: We can't retrieve data from region different than the lambda region

  const client = new CloudWatchClient();
  const command = new GetMetricDataCommand(params);

  const { MetricDataResults: dataPoints } = await client.send(command);
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
  return recordRows({ dataPoints, params });
};

export const handler = async (request, _context, _callback) => {
  const newRecords = await getCloudwatchData();

  return setupFivetranResponse({
    state: request.state,
    newRecords,
  });
};
