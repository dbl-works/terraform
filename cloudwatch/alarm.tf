resource "aws_cloudwatch_metric_alarm" "cluster_cpu" {
  alarm_name          = "${var.project}-${var.environment}-${var.region}-cluster-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Monitors ECS CPU utilization"
  alarm_actions       = var.sns_topic_arns
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = "web"
  }
}

resource "aws_cloudwatch_metric_alarm" "cluster_memory" {
  alarm_name          = "${var.project}-${var.environment}-${var.region}-cluster-memory-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Monitors ECS Memory utilization"
  alarm_actions       = var.sns_topic_arns
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = "web"
  }
}

resource "aws_cloudwatch_metric_alarm" "db_memory" {
  alarm_name          = "${var.project}-${var.environment}-${var.region}-db-freeableMemory"
  comparison_operator = "LessThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 128 * 1024 * 1024
  alarm_description   = "Monitors RDS Freeable Memory"
  alarm_actions       = var.sns_topic_arns
  dimensions = {
    DBInstanceIdentifier = var.database_name
  }
}

# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Limits.html#RDS_Limits.MaxConnections
# LEAST({DBInstanceClassMemory/9531392}, 5000)
resource "aws_cloudwatch_metric_alarm" "db_connection" {
  alarm_name          = "${var.project}-${var.environment}-${var.region}-db-database-connections"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 1000
  alarm_description   = "Monitors DB Connection"
  alarm_actions       = var.sns_topic_arns
  dimensions = {
    DBInstanceIdentifier = var.database_name
  }
}

resource "aws_cloudwatch_metric_alarm" "db_cpu" {
  alarm_name          = "${var.project}-${var.environment}-${var.region}-db-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 95
  alarm_description   = "Monitors DB CPU Usage"
  alarm_actions       = var.sns_topic_arns
  dimensions = {
    DBInstanceIdentifier = var.database_name
  }
}

resource "aws_cloudwatch_metric_alarm" "db_storage" {
  alarm_name          = "${var.project}-${var.environment}-${var.region}-db-free-storage"
  comparison_operator = "LessThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 10 * 1000 * 1024 * 1024
  alarm_description   = "Monitors DB Free Storage"
  alarm_actions       = var.sns_topic_arns
  dimensions = {
    DBInstanceIdentifier = var.database_name
  }
}

resource "aws_cloudwatch_metric_alarm" "db_read" {
  alarm_name          = "${var.project}-${var.environment}-${var.region}-db-readlatency"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "ReadLatency"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 0.25
  alarm_description   = "Monitors DB Read Latency"
  alarm_actions       = var.sns_topic_arns
  dimensions = {
    DBInstanceIdentifier = var.database_name
  }
}

resource "aws_cloudwatch_metric_alarm" "db_write" {
  alarm_name          = "${var.project}-${var.environment}-${var.region}-db-writelatency"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "ReadLatency"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 0.25
  alarm_description   = "Monitors DB Write Latency"
  alarm_actions       = var.sns_topic_arns
  dimensions = {
    DBInstanceIdentifier = var.database_name
  }
}

resource "aws_cloudwatch_metric_alarm" "db_network_receive" {
  alarm_name          = "${var.project}-${var.environment}-${var.region}-db-network-receive-throughput"
  comparison_operator = "LessThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "NetworkReceiveThroughput"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "Monitors DB NetworkReceiveThroughput"
  dimensions = {
    DBInstanceIdentifier = var.database_name
  }
}

resource "aws_cloudwatch_metric_alarm" "db_network_transmit" {
  alarm_name          = "${var.project}-${var.environment}-${var.region}-db-network-transmit-throughput"
  comparison_operator = "LessThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "NetworkTransmitThroughput"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "Monitors DB NetworkTransmitThroughput"
  dimensions = {
    DBInstanceIdentifier = var.database_name
  }
}

resource "aws_cloudwatch_composite_alarm" "db_network" {
  alarm_name        = "${var.project}-${var.environment}-${var.region}-db-network"
  alarm_description = "Monitors DB Network"

  alarm_actions = var.sns_topic_arns

  alarm_rule = "ALARM(${aws_cloudwatch_metric_alarm.db_network_receive.alarm_name}) AND ALARM(${aws_cloudwatch_metric_alarm.db_network_transmit.alarm_name})"
}

resource "aws_cloudwatch_metric_alarm" "db_read_iops" {
  alarm_name          = "${var.project}-${var.environment}-${var.region}-db-read-iops"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "ReadIOPS"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 2500
  alarm_description   = "Monitors DB Read IOPS"
  alarm_actions       = var.sns_topic_arns
  dimensions = {
    DBInstanceIdentifier = var.database_name
  }
}

resource "aws_cloudwatch_metric_alarm" "db_write_iops" {
  alarm_name          = "${var.project}-${var.environment}-${var.region}-db-write-iops"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "WriteIOPS"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 2500
  alarm_description   = "Monitors DB Write IOPS"
  alarm_actions       = var.sns_topic_arns
  dimensions = {
    DBInstanceIdentifier = var.database_name
  }
}


resource "aws_cloudwatch_metric_alarm" "redis_cpu" {
  alarm_name          = "${var.project}-${var.environment}-${var.region}-redis-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "EngineCPUUtilization"
  namespace           = "AWS/ElastiCache"
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Monitors Redis CPU"
  alarm_actions       = var.sns_topic_arns
  dimensions = {
    ReplicationGroupId = var.elasticache_cluster_name
  }
}

resource "aws_cloudwatch_metric_alarm" "redis_memory" {
  alarm_name          = "${var.project}-${var.environment}-${var.region}-redis-memory-usage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "DatabaseMemoryUsageCountedForEvictPercentage"
  namespace           = "AWS/ElastiCache"
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Monitors Redis Memory"
  alarm_actions       = var.sns_topic_arns
  dimensions = {
    ReplicationGroupId = var.elasticache_cluster_name
  }
}

resource "aws_cloudwatch_metric_alarm" "error_rate" {
  alarm_name          = "${var.project}-${var.environment}-${var.region}-error-rate"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  threshold           = "10"
  alarm_description   = "Request error rate has exceeded 10%"
  alarm_actions       = var.sns_topic_arns

  metric_query {
    id          = "e1"
    expression  = "m2/m1*100"
    label       = "Error Rate"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = "RequestCount"
      namespace   = "AWS/ApplicationELB"
      period      = "120"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        LoadBalancer = var.alb_arn_suffix
      }
    }
  }

  metric_query {
    id = "m2"

    metric {
      metric_name = "HTTPCode_ELB_5XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = "120"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        LoadBalancer = var.alb_arn_suffix
      }
    }
  }
}
