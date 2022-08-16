locals {
  cluster_metrics = [
    {
      "type" : "text",
      "x" : 0,
      "y" : 0,
      "width" : 18,
      "height" : 1,
      "properties" : {
        "markdown" : "# Cluster & Load Balancer - ${var.region}"
      }
    },
    {
      "height" : 6,
      "width" : 9,
      "y" : 1,
      "x" : 0,
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
      "y" : 7,
      "x" : 9,
      "type" : "metric",
      "properties" : {
        "metrics" : [
          ["ECS/ContainerInsights", "CpuUtilized", "ServiceName", "web", "ClusterName", "${var.cluster_name}"]
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
      "y" : 7,
      "x" : 0,
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
        "title" : "Throughput",
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
      "y" : 1,
      "x" : 9,
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
      "y" : 13,
      "x" : 0,
      "width" : 18,
      "height" : 1,
      "properties" : {
        "markdown" : "# Database"
      }
    },
    {
      "height" : 6,
      "width" : 9,
      "y" : 14,
      "x" : 0,
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
      "y" : 14,
      "x" : 9,
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
      "y" : 20,
      "x" : 0,
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
      "y" : 20,
      "x" : 9,
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
      "y" : 26,
      "x" : 0,
      "type" : "metric",
      "properties" : {
        "title" : "DB Read/Write Latency - ${var.region}",
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
      "y" : 26,
      "x" : 9,
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
      "y" : 32,
      "x" : 0,
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
      "y" : 38,
      "x" : 0,
      "width" : 18,
      "height" : 1,
      "properties" : {
        "markdown" : "# Redis"
      }
    },
    {
      "type" : "metric",
      "y" : 39,
      "x" : 0,
      "width" : 9,
      "height" : 6,
      "properties" : {
        "title" : "Redis CPU Utilization (%)",
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
      "y" : 39,
      "x" : 9,
      "width" : 9,
      "height" : 6,
      "properties" : {
        "title" : "Redis Available Memory (%)",
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
  dashboard_name = var.dashboard_name

  dashboard_body = jsonencode({
    "widgets" : concat(local.cluster_metrics, local.database_metrics, local.elasticache_metrics)
  })
}
