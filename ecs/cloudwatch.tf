locals {
  alb_cloudwatch_metrics = [for alb in aws_alb.alb : [
    {
      "height" : 6,
      "width" : 9,
      "y" : 6,
      "x" : 0,
      "type" : "metric",
      "properties" : {
        "metrics" : [
          ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${alb.arn_suffix}"]
        ],
        "view" : "timeSeries",
        "stacked" : true,
        "region" : "${local.region}",
        "stat" : "Sum",
        "period" : 60,
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
      "y" : 0,
      "x" : 9,
      "type" : "metric",
      "properties" : {
        "metrics" : [
          ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "${alb.arn_suffix}", { "label" : "Average", "id" : "m1", "stat" : "Average" }],
          ["...", { "id" : "m2", "label" : "p95" }],
          ["...", { "id" : "m3", "stat" : "p90", "label" : "p90" }]
        ],
        "view" : "timeSeries",
        "stacked" : false,
        "region" : "${local.region}",
        "stat" : "p95",
        "period" : 60,
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
  ]]
  metrics = [
    {
      "height" : 6,
      "width" : 9,
      "y" : 6,
      "x" : 9,
      "type" : "metric",
      "properties" : {
        "metrics" : [
          ["ECS/ContainerInsights", "CpuUtilized", "ServiceName", "web", "ClusterName", "${local.name}"]
        ],
        "view" : "timeSeries",
        "stacked" : false,
        "region" : "${local.region}",
        "title" : "CPU Usage",
        "period" : 60,
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
      "y" : 0,
      "x" : 0,
      "type" : "metric",
      "properties" : {
        "metrics" : [
          [{ "expression" : "100*(m1/m2)", "label" : "MemoryUsage", "id" : "e1", "region" : "${local.region}", "yAxis" : "left" }],
          ["ECS/ContainerInsights", "MemoryUtilized", "ServiceName", "web", "ClusterName", "${local.name}", { "id" : "m1", "visible" : false }],
          [".", "MemoryReserved", ".", ".", ".", ".", { "id" : "m2", "visible" : false }]
        ],
        "view" : "timeSeries",
        "stacked" : true,
        "region" : "${local.region}",
        "title" : "Memory Usage",
        "period" : 60,
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
    }
  ]
}

resource "aws_cloudwatch_dashboard" "main" {
  count          = var.enable_dashboard ? 1 : 0
  dashboard_name = "${local.name}-ecs"

  dashboard_body = jsonencode({
    widgets = flatten(concat(
      local.alb_cloudwatch_metrics,
      local.metrics,
    ))
  })
}
