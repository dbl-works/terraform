locals {
  performance_metrics = [
    {
      "height" : 5,
      "width" : 5,
      "type" : "metric",
      "properties" : {
        "title" : "Average Response Time",
        "view" : "singleValue",
        "sparkline" : true,
        "metrics" : [
          ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix]
        ],
        "region" : var.region
      }
    },
    {
      "height" : 5,
      "width" : 5,
      "type" : "metric",
      "properties" : {
        "title" : "Request Count (1m)",
        "view" : "singleValue",
        "sparkline" : true,
        "stat" : "Sum",
        "metrics" : [
          [{ "expression" : "SELECT SUM(RequestCount) FROM SCHEMA(\"AWS/ApplicationELB\", LoadBalancer) WHERE LoadBalancer = '${var.alb_arn_suffix}'", "label" : "Request Count", "region" : var.region, "period" : 60 }]
        ],
        "region" : var.region
      }
    },
    {
      "height" : 5,
      "width" : 5,
      "type" : "metric",
      "properties" : {
        "title" : "Request Count (1d)",
        "view" : "singleValue",
        "sparkline" : true,
        "stat" : "Sum",
        "metrics" : [
          [{ "expression" : "SELECT SUM(RequestCount) FROM SCHEMA(\"AWS/ApplicationELB\", LoadBalancer) WHERE LoadBalancer = '${var.alb_arn_suffix}'", "label" : "Request Count", "region" : var.region, "period" : 86400 }]
        ],
        "region" : var.region
      }
    },
    {
      "height" : 6,
      "width" : 6,
      "type" : "metric",
      "properties" : {
        "title" : "CPU Utilization",
        "metrics" : [
          [{ "expression" : "SELECT AVG(CPUUtilization) FROM SCHEMA(\"AWS/ECS\", ClusterName,ServiceName) WHERE ServiceName = 'web' GROUP BY ClusterName, ServiceName" }]
        ],
        "view" : "bar",
        "stat" : "Average",
        "region" : var.region,
        "period" : var.period
      }
    },
    {
      "height" : 6,
      "width" : 6,
      "type" : "metric",
      "properties" : {
        "title" : "Memory Utilization",
        "metrics" : [
          [{ "expression" : "SELECT AVG(MemoryUtilization) FROM SCHEMA(\"AWS/ECS\", ClusterName,ServiceName) WHERE ServiceName = 'web' GROUP BY ClusterName,ServiceName" }]
        ],
        "view" : "bar",
        "stat" : "Average",
        "region" : var.region,
        "period" : var.period
      }
    },
    {
      "type" : "metric",
      "width" : 12,
      "height" : 6,
      "properties" : {
        "metrics" : [
          ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${var.alb_arn_suffix}", { "label" : "RequestCount per day" }]
        ],
        "view" : "timeSeries",
        "stacked" : false,
        "region" : var.region,
        "stat" : "Sum",
        "period" : 86400,
      }
    }
  ]

  cluster_metrics = [
    {
      "type" : "text",
      "width" : 18,
      "height" : 1,
      "properties" : {
        "markdown" : "# Cluster"
      }
    },
    {
      "height" : 6,
      "width" : 9,
      "type" : "metric",
      "properties" : {
        "metrics" : [
          [{ "expression" : "100*(m1/m2)", "label" : "MemoryUsage", "id" : "e1", "region" : "${var.region}", "yAxis" : "left" }],
          ["ECS/ContainerInsights", "MemoryUtilized", "ServiceName", "web", "ClusterName", "${var.cluster_name}", { "id" : "m1", "visible" : false }],
          [".", "MemoryReserved", ".", ".", ".", ".", { "id" : "m2", "visible" : false }]
        ],
        "view" : "timeSeries",
        "stacked" : true,
        "region" : "${var.region}",
        "title" : "Memory Usage",
        "period" : var.period,
        "stat" : "Maximum",
        "yAxis" : {
          "left" : {
            "min" : 0,
            "max" : 100,
            "showUnits" : false
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
          ["AWS/ECS", "CPUUtilization", "ServiceName", "web", "ClusterName", "${var.cluster_name}"]
        ],
        "view" : "timeSeries",
        "stacked" : false,
        "region" : "${var.region}",
        "title" : "CPU Usage",
        "period" : var.period,
        "stat" : "Maximum",
        "yAxis" : {
          "left" : {
            "min" : 0,
            "showUnits" : false
          },
          "right" : {
            "showUnits" : true
          }
        }
      }
    },
    {
      "height" : 6,
      "width" : 9,
      "type" : "metric",
      "properties" : {
        "metrics" : [
          ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${var.alb_arn_suffix}"]
        ],
        "view" : "timeSeries",
        "stacked" : true,
        "region" : "${var.region}",
        "stat" : "Sum",
        "period" : var.period,
        "title" : "Throughput/min",
        "yAxis" : {
          "left" : {
            "showUnits" : false,
            "min" : 0
          }
        }
      }
    },
    {
      "height" : 6,
      "width" : 9,
      "type" : "metric",
      "properties" : {
        "metrics" : [
          ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "${var.alb_arn_suffix}", { "label" : "Average", "id" : "m1", "stat" : "Average" }],
          ["...", { "id" : "m2", "label" : "p95" }],
          ["...", { "id" : "m3", "stat" : "p90", "label" : "p90" }]
        ],
        "view" : "timeSeries",
        "stacked" : false,
        "region" : "${var.region}",
        "stat" : "p95",
        "period" : var.period,
        "title" : "Response Time",
        "yAxis" : {
          "left" : {
            "showUnits" : false,
            "min" : 0
          }
        },
        "setPeriodToTimeRange" : true
      }
    }
  ]

  database_metrics = [
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
          ["AWS/RDS", "FreeableMemory", "DBInstanceIdentifier", "${var.database_name}"]
        ],
        "region" : "${var.region}",
        "period" : var.period,
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
          ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "${var.database_name}"]
        ],
        "region" : "${var.region}",
        "period" : var.period
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
          ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "${var.database_name}"]
        ],
        "region" : "${var.region}",
        "period" : var.period
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
          ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", "${var.database_name}"]
        ],
        "region" : "${var.region}",
        "period" : var.period
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
          ["AWS/RDS", "ReadLatency", "DBInstanceIdentifier", "${var.database_name}"],
          [".", "WriteLatency", ".", "."]
        ],
        "region" : "${var.region}",
        "period" : var.period
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
          ["AWS/RDS", "NetworkReceiveThroughput", "DBInstanceIdentifier", "${var.database_name}"],
          [".", "NetworkTransmitThroughput", ".", "."]
        ],
        "region" : "${var.region}",
        "period" : var.period
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
          ["AWS/RDS", "ReadIOPS", "DBInstanceIdentifier", "${var.database_name}"],
          [".", "WriteIOPS", ".", "."]
        ],
        "region" : "${var.region}",
        "period" : var.period
      }
    }
  ]

  elasticache_metrics = [
    {
      "type" : "text",
      "width" : 18,
      "height" : 1,
      "properties" : {
        "markdown" : "# Redis"
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
          ["AWS/ElastiCache", "EngineCPUUtilization", "ReplicationGroupId", "${var.elasticache_cluster_name}"]
        ],
        "region" : "${var.region}",
        "period" : var.period
      }
    },
    {
      "type" : "metric",
      "width" : 9,
      "height" : 6,
      "properties" : {
        "title" : "Redis Available Memory",
        "view" : "timeSeries",
        "stacked" : false,
        "metrics" : [
          ["AWS/ElastiCache", "DatabaseMemoryUsageCountedForEvictPercentage", "ReplicationGroupId", "${var.elasticache_cluster_name}"]
        ],
        "region" : "${var.region}",
        "period" : var.period
      }
    }
  ]
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.dashboard_name}-${var.region}"

  dashboard_body = jsonencode({
    "widgets" : concat(local.performance_metrics, local.cluster_metrics, local.database_metrics, local.elasticache_metrics)
  })
}
