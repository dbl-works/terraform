locals {
  alb_performance_metrics = [
    for name in var.alb_arn_suffixes : [
      {
        "height" : 4,
        "width" : 4,
        "type" : "metric",
        "properties" : {
          "title" : "Avg Response Time (ms)",
          "view" : "singleValue",
          "sparkline" : true,
          "metrics" : [
            [{ "expression" : "m1*1000", "id" : "e1", "label" : "ms" }],
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", name, { "id" : "m1", "visible" : false }]
          ],
          "region" : var.region,
          "unit" : "Milliseconds"
        }
      },
      {
        "height" : 4,
        "width" : 4,
        "type" : "metric",
        "properties" : {
          "title" : "Request Count per min",
          "view" : "singleValue",
          "sparkline" : true,
          "stat" : "Sum",
          "period" : 60,
          "metrics" : [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", name, { "label" : name }]
          ],
          "region" : var.region
        }
      }
    ]
  ]

  elasticache_performance_metrics = [
    for name in var.elasticache_cluster_names :
    {
      "height" : 4,
      "width" : 4,
      "type" : "metric",
      "properties" : {
        "title" : "Redis Memory Usage",
        "view" : "singleValue",
        "sparkline" : true,
        "period" : var.metric_period,
        "metrics" : [
          ["AWS/ElastiCache", "DatabaseMemoryUsageCountedForEvictPercentage", "ReplicationGroupId", "${name}", { "label" : name }]
        ],
        "region" : var.region
      }
    }
  ]

  database_performance_metrics = [

    for name in var.database_identifiers : [
      {
        "height" : 4,
        "width" : 4,
        "type" : "metric",
        "properties" : {
          "title" : "DB Read IOPS (Count/s)",
          "view" : "singleValue",
          "sparkline" : true,
          "stat" : "Sum",
          "metrics" : [
            ["AWS/RDS", "ReadIOPS", "DBInstanceIdentifier", name, { "label" : name }],
          ],
          "region" : var.region
        }
      },
      {
        "height" : 4,
        "width" : 4,
        "type" : "metric",
        "properties" : {
          "title" : "DB Write IOPS (Count/s)",
          "view" : "singleValue",
          "sparkline" : true,
          "stat" : "Sum",
          "metrics" : [
            ["AWS/RDS", "WriteIOPS", "DBInstanceIdentifier", name, { "label" : name }],
          ],
          "region" : var.region
        }
      }
    ]
  ]

  alb_status_metrics = [
    for name in var.alb_arn_suffixes : [
      {
        "type" : "metric",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "title" : "RequestCount per day",
          "metrics" : [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", name, { label : name }]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "region" : var.region,
          "stat" : "Sum",
          "period" : 86400,
        }
      },
      {
        "type" : "metric",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "title" : "Response Status Count (1 day)",
          "metrics" : [
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", name, { "label" : "5xx Count" }],
            [".", "HTTPCode_Target_4XX_Count", ".", ".", { "label" : "4xx Count" }],
            [".", "HTTPCode_Target_2XX_Count", ".", ".", { "label" : "2xx Count" }]
          ],
          "view" : "bar",
          "region" : var.region,
          "stat" : "Sum",
          "period" : 86400
        }
      }
    ]
  ]


  cluster_metrics = [
    for name in var.cluster_names : [
      {
        "height" : 6,
        "width" : 9,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            ["AWS/ECS", "MemoryUtilization", "ServiceName", "web", "ClusterName", name, { "id" : "m1", "label" : "Max", "stat" : "Maximum" }],
            ["...", { "id" : "m2", "label" : "Avg", "stat" : "Average" }],
            ["...", { "id" : "m3", "label" : "p99", "stat" : "p99" }],
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "${var.region}",
          "title" : "Memory Usage",
          "period" : var.metric_period,
          "yAxis" : {
            "left" : {
              "min" : 0,
              "max" : 100,
              "showUnits" : true
            }
          },
          "setPeriodToTimeRange" : true
        }
      },
      {
        "height" : 6,
        "width" : 9,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            ["AWS/ECS", "CPUUtilization", "ServiceName", "web", "ClusterName", name, { "id" : "m1", "label" : "Max", "stat" : "Maximum" }],
            ["...", { "id" : "m2", "label" : "Avg", "stat" : "Average" }],
            ["...", { "id" : "m3", "label" : "p99", "stat" : "p99" }],
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "${var.region}",
          "title" : "CPU Usage",
          "period" : var.metric_period,
          "yAxis" : {
            "left" : {
              "min" : 0,
              "max" : 100,
              "showUnits" : true
            }
          },
        }
      },
    ]
  ]

  alb_metrics = [
    for name in var.alb_arn_suffixes : [
      {
        "height" : 6,
        "width" : 9,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", name, { "label" : name }]
          ],
          "view" : "timeSeries",
          "stacked" : true,
          "region" : "${var.region}",
          "stat" : "Sum",
          "period" : var.metric_period,
          "title" : "Throughput",
        }
      },
      {
        "height" : 6,
        "width" : 9,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", name, { "label" : "Max", "id" : "m1", "stat" : "Maximum" }],
            ["...", { "id" : "m3", "label" : "p99.9", "stat" : "p99.9" }],
            ["...", { "id" : "m2", "label" : "p99", "stat" : "p99" }]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "region" : var.region,
          "period" : var.metric_period,
          "title" : "Response Time",
          "yAxis" : {
            "left" : {
              "min" : 0
            }
          },
          "setPeriodToTimeRange" : true
        }
      }
    ]
  ]

  database_metrics = [
    for name in var.database_identifiers : [
      {
        "type" : "text",
        "width" : 18,
        "height" : 1,
        "properties" : {
          "markdown" : "# Database"
        }
      },
      {
        "height" : 6,
        "width" : 9,
        "type" : "metric",
        "properties" : {
          "title" : "DB Freeable Memory",
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/RDS", "FreeableMemory", "DBInstanceIdentifier", name],
            [".", "SwapUsage", ".", name]
          ],
          "region" : "${var.region}",
          "period" : var.metric_period,
          "setPeriodToTimeRange" : true
        }
      },
      {
        "height" : 6,
        "width" : 9,
        "type" : "metric",
        "properties" : {
          "title" : "DB Connections",
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "${name}", { "label" : name }]
          ],
          "region" : "${var.region}",
          "period" : var.metric_period
        }
      },
      {
        "height" : 6,
        "width" : 9,
        "type" : "metric",
        "properties" : {
          "title" : "DB CPU Utilization",
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "${name}", { "label" : name }]
          ],
          "region" : "${var.region}",
          "period" : var.metric_period,
          "yAxis" : {
            "left" : {
              "min" : 0,
              "max" : 100,
              "showUnits" : true
            }
          },
        }
      },
      {
        "height" : 6,
        "width" : 9,
        "type" : "metric",
        "properties" : {
          "title" : "DB Free Storage Space",
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", "${name}", { "label" : name }]
          ],
          "region" : "${var.region}",
          "period" : var.metric_period
        }
      },
      {
        "height" : 6,
        "width" : 9,
        "type" : "metric",
        "properties" : {
          "title" : "DB Read/Write Latency",
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/RDS", "ReadLatency", "DBInstanceIdentifier", "${name}"],
            [".", "WriteLatency", ".", "."]
          ],
          "region" : "${var.region}",
          "period" : var.metric_period
        }
      },
      {
        "type" : "metric",
        "width" : 9,
        "height" : 6,
        "properties" : {
          "title" : "DB Network I/O",
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/RDS", "NetworkReceiveThroughput", "DBInstanceIdentifier", "${name}"],
            [".", "NetworkTransmitThroughput", ".", "."]
          ],
          "region" : "${var.region}",
          "period" : var.metric_period
        }
      },
      {
        "type" : "metric",
        "width" : 9,
        "height" : 6,
        "properties" : {
          "title" : "DB Read/Write IOPS",
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            [{ "expression" : "m1+m2", "label" : "Total IOPS", "id" : "e1" }],
            ["AWS/RDS", "ReadIOPS", "DBInstanceIdentifier", name, { "id" : "m1" }],
            [".", "WriteIOPS", ".", ".", { "id" : "m2" }]
          ],
          "region" : "${var.region}",
          "period" : var.metric_period
        }
      },
      {
        "type" : "metric",
        "width" : 9,
        "height" : 6,
        "properties" : {
          "title" : "DB Read/Write Throughput",
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/RDS", "ReadThroughput", "DBInstanceIdentifier", name],
            [".", "WriteThroughput", ".", "."]
          ],
          "region" : "${var.region}",
          "period" : var.metric_period
        }
      }
    ]
  ]

  database_replica_metrics = var.db_is_read_replica ? [
    for name in var.database_identifiers : [
      {
        "type" : "metric",
        "width" : 9,
        "height" : 6,
        "properties" : {
          "title" : "ReplicaLag"
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/RDS", "ReplicaLag", "DBInstanceIdentifier", name]
          ],
          "region" : var.region,
        }
      }
    ]
  ] : []

  elasticache_metrics = [
    for name in var.elasticache_cluster_names : [
      {
        "type" : "text",
        "width" : 18,
        "height" : 1,
        "properties" : {
          "markdown" : "# Redis - ${name}"
        }
      },
      {
        "type" : "metric",
        "width" : 9,
        "height" : 6,
        "properties" : {
          "title" : "Redis CPU Utilization",
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/ElastiCache", "EngineCPUUtilization", "ReplicationGroupId", "${name}", { "label" : name }]
          ],
          "region" : var.region,
          "period" : var.metric_period,
          "yAxis" : {
            "left" : {
              "min" : 0,
              "max" : 100,
              "showUnits" : true
            }
          },
        }
      },
      {
        "type" : "metric",
        "width" : 9,
        "height" : 6,
        "properties" : {
          "title" : "Redis Memory Usage",
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            # Percentage of the memory for the cluster that is in use, excluding memory used for overhead and COB.
            # https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/CacheMetrics.Redis.html
            ["AWS/ElastiCache", "DatabaseMemoryUsageCountedForEvictPercentage", "ReplicationGroupId", "${name}", { "label" : name }]
          ],
          "region" : var.region,
          "period" : var.metric_period,
          "yAxis" : {
            "left" : {
              "min" : 0,
              "max" : 100,
              "showUnits" : true
            }
          },
        }
      }
    ]
  ]
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = local.name

  dashboard_body = jsonencode({
    "widgets" : flatten(concat(
      local.alb_performance_metrics,
      local.elasticache_performance_metrics,
      local.database_performance_metrics,
      local.alb_status_metrics,
      [
        {
          "type" : "text",
          "width" : 18,
          "height" : 1,
          "properties" : {
            "markdown" : "# Cluster"
          }
        }
      ],
      local.cluster_metrics,
      local.alb_metrics,
      local.database_metrics,
      local.database_replica_metrics,
      local.elasticache_metrics,
      var.custom_metrics
    ))
  })
}
