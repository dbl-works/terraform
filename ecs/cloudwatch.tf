resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project}-${var.environment}-ecs"

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "height": 6,
      "width": 9,
      "y": 6,
      "x": 9,
      "type": "metric",
      "properties": {
        "metrics": [
          [ "ECS/ContainerInsights", "CpuUtilized", "ServiceName", "web", "ClusterName", "${var.project}-${var.environment}" ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "${var.region}",
        "title": "CPU Usage",
        "period": 60,
        "stat": "Maximum",
        "yAxis": {
          "left": {
            "min": 0,
            "showUnits": false
          },
          "right": {
            "showUnits": true
          }
        }
      }
    },
    {
      "height": 6,
      "width": 9,
      "y": 0,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [ { "expression": "100*(m1/m2)", "label": "MemoryUsage", "id": "e1", "region": "${var.region}", "yAxis": "left" } ],
          [ "ECS/ContainerInsights", "MemoryUtilized", "ServiceName", "web", "ClusterName", "${var.project}-${var.environment}", { "id": "m1", "visible": false } ],
          [ ".", "MemoryReserved", ".", ".", ".", ".", { "id": "m2", "visible": false } ]
        ],
        "view": "timeSeries",
        "stacked": true,
        "region": "${var.region}",
        "title": "Memory Usage",
        "period": 60,
        "stat": "Maximum",
        "yAxis": {
          "left": {
            "min": 0,
            "max": 100,
            "showUnits": false
          }
        },
        "setPeriodToTimeRange": true
      }
    },
    {
      "height": 6,
      "width": 9,
      "y": 6,
      "x": 0,
      "type": "metric",
      "properties": {
        "metrics": [
          [ "AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${aws_alb.alb.arn_suffix}" ]
        ],
        "view": "timeSeries",
        "stacked": true,
        "region": "${var.region}",
        "stat": "Sum",
        "period": 60,
        "title": "Throughput",
        "yAxis": {
          "left": {
            "showUnits": false,
            "min": 0
          }
        }
      }
    },
    {
      "height": 6,
      "width": 9,
      "y": 0,
      "x": 9,
      "type": "metric",
      "properties": {
        "metrics": [
          [ "AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "${aws_alb.alb.arn_suffix}", { "label": "Average", "id": "m1", "stat": "Average" } ],
          [ "...", { "id": "m2", "label": "p95" } ],
          [ "...", { "id": "m3", "stat": "p90", "label": "p90" } ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "${var.region}",
        "stat": "p95",
        "period": 60,
        "title": "Response Time",
        "yAxis": {
          "left": {
            "showUnits": false,
            "min": 0
          }
        },
        "setPeriodToTimeRange": true
      }
    }
  ]
}
EOF
}
