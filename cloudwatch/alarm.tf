resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name          = "${var.dashboard_name}-ecs-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Monitors ECS CPU utilization"
  alarm_actions       = [aws_sns_topic.cloudwatch_slack.arn]
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = "web"
  }
}

resource "aws_cloudwatch_metric_alarm" "memory" {
  alarm_name          = "${var.dashboard_name} Memory Utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Monitors ECS Memory utilization"
  alarm_actions       = [aws_sns_topic.cloudwatch_slack.arn]
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = "web"
  }
}

resource "aws_cloudwatch_metric_alarm" "db_memory" {
  alarm_name          = "${var.dashboard_name}-rds-memory"
  comparison_operator = "LessThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 128 * 1024 * 1024
  alarm_description   = "Monitors RDS Freeable Memory"
  alarm_actions       = [aws_sns_topic.cloudwatch_slack.arn]
  dimensions = {
    DBInstanceIdentifier = var.database_name
  }
}

# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Limits.html#RDS_Limits.MaxConnections
# LEAST({DBInstanceClassMemory/9531392}, 5000)
resource "aws_cloudwatch_metric_alarm" "db_connection" {
  alarm_name          = "${var.dashboard_name}-rds-connection"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 1000
  alarm_description   = "Monitors DB Connection"
  alarm_actions       = [aws_sns_topic.cloudwatch_slack.arn]
  dimensions = {
    DBInstanceIdentifier = var.database_name
  }
}

resource "aws_cloudwatch_metric_alarm" "db_cpu" {
  alarm_name          = "${var.dashboard_name}-rds-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 95
  alarm_description   = "Monitors DB CPU Usage"
  alarm_actions       = [aws_sns_topic.cloudwatch_slack.arn]
  dimensions = {
    DBInstanceIdentifier = var.database_name
  }
}

resource "aws_cloudwatch_metric_alarm" "db_storage" {
  alarm_name          = "${var.dashboard_name}-rds-storage"
  comparison_operator = "LessThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 10 * 1000 * 1024 * 1024
  alarm_description   = "Monitors DB Free Storage"
  alarm_actions       = [aws_sns_topic.cloudwatch_slack.arn]
  dimensions = {
    DBInstanceIdentifier = var.database_name
  }
}

resource "aws_cloudwatch_metric_alarm" "db_read" {
  alarm_name          = "${var.dashboard_name}-rds-read"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "ReadLatency"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 0.25
  alarm_description   = "Monitors DB Read Latency"
  alarm_actions       = [aws_sns_topic.cloudwatch_slack.arn]
  dimensions = {
    DBInstanceIdentifier = var.database_name
  }
}

resource "aws_cloudwatch_metric_alarm" "db_write" {
  alarm_name          = "${var.dashboard_name}-rds-write"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "ReadLatency"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 0.25
  alarm_description   = "Monitors DB Write Latency"
  alarm_actions       = [aws_sns_topic.cloudwatch_slack.arn]
  dimensions = {
    DBInstanceIdentifier = var.database_name
  }
}

resource "aws_cloudwatch_metric_alarm" "db_network_receive" {
  alarm_name          = "${var.dashboard_name}-rds-network-receive"
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
  alarm_name          = "${var.dashboard_name}-rds-network-transmit"
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
  alarm_description = "Monitors DB Network"
  alarm_name        = "${var.dashboard_name}-rds-network"

  alarm_actions = [aws_sns_topic.cloudwatch_slack.arn]

  alarm_rule = "ALARM(${aws_cloudwatch_metric_alarm.db_network_receive.alarm_name}) AND ALARM(${aws_cloudwatch_metric_alarm.db_network_transmit.alarm_name})"
}

resource "aws_cloudwatch_metric_alarm" "db_read_iops" {
  alarm_name          = "${var.dashboard_name}-rds-read-iops"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "ReadIOPS"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 2500
  alarm_description   = "Monitors DB Read IOPS"
  alarm_actions       = [aws_sns_topic.cloudwatch_slack.arn]
  dimensions = {
    DBInstanceIdentifier = var.database_name
  }
}

resource "aws_cloudwatch_metric_alarm" "db_write_iops" {
  alarm_name          = "${var.dashboard_name}-rds-write-iops"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "WriteIOPS"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 2500
  alarm_description   = "Monitors DB Write IOPS"
  alarm_actions       = [aws_sns_topic.cloudwatch_slack.arn]
  dimensions = {
    DBInstanceIdentifier = var.database_name
  }
}


resource "aws_cloudwatch_metric_alarm" "redis_cpu" {
  alarm_name          = "${var.dashboard_name}-redis-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "EngineCPUUtilization"
  namespace           = "AWS/ElastiCache"
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Monitors Redis CPU"
  alarm_actions       = [aws_sns_topic.cloudwatch_slack.arn]
  dimensions = {
    ReplicationGroupId = var.elasticache_cluster_name
  }
}

resource "aws_cloudwatch_metric_alarm" "redis_memory" {
  alarm_name          = "${var.dashboard_name}-redis-memory"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "DatabaseMemoryUsageCountedForEvictPercentage"
  namespace           = "AWS/ElastiCache"
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Monitors Redis Memory"
  alarm_actions       = [aws_sns_topic.cloudwatch_slack.arn]
  dimensions = {
    ReplicationGroupId = var.elasticache_cluster_name
  }
}
