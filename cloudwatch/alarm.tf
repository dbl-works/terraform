resource "aws_cloudwatch_metric_alarm" "cluster_cpu" {
  count               = length(var.cluster_names)
  alarm_name          = "${var.project}-${var.environment}-cluster-${var.cluster_names[count.index]}-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alert when ECS CPU utilization >= 80%"
  alarm_actions       = var.sns_topic_arns
  dimensions = {
    ClusterName = var.cluster_names[count.index]
    ServiceName = "web"
  }
}

resource "aws_cloudwatch_metric_alarm" "cluster_memory" {
  count               = length(var.cluster_names)
  alarm_name          = "${var.project}-${var.environment}-cluster-${var.cluster_names[count.index]}-memory-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alert when ECS Memory utilization >= 80%"
  alarm_actions       = var.sns_topic_arns
  dimensions = {
    ClusterName = var.cluster_names[count.index]
    ServiceName = "web"
  }
}

resource "aws_cloudwatch_metric_alarm" "db_memory" {
  count               = length(var.database_identifiers)
  alarm_name          = "${var.project}-${var.environment}-db-${var.database_identifiers[count.index]}-freeableMemory"
  comparison_operator = "LessThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = floor(local.db_instance_class_memory_in_bytes * 0.10)
  alarm_description   = "Alert when DB Freeable Memory <= 10%"
  alarm_actions       = var.sns_topic_arns
  dimensions = {
    DBInstanceIdentifier = var.database_identifiers[count.index]
  }
}

# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Limits.html#RDS_Limits.MaxConnections
resource "aws_cloudwatch_metric_alarm" "db_connection" {
  count               = length(var.database_identifiers)
  alarm_name          = "${var.project}-${var.environment}-db-${var.database_identifiers[count.index]}-db-connections"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = floor(local.db_instance_class_memory_in_bytes / 12582880 * 0.80)
  alarm_description   = "Alert when DB Connection >= 80% of the max connection"
  alarm_actions       = var.sns_topic_arns
  dimensions = {
    DBInstanceIdentifier = var.database_identifiers[count.index]
  }
}

resource "aws_cloudwatch_metric_alarm" "db_cpu" {
  count               = length(var.database_identifiers)
  alarm_name          = "${var.project}-${var.environment}-db-${var.database_identifiers[count.index]}-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 95
  alarm_description   = "Alert when DB CPU Usage >= 90%"
  alarm_actions       = var.sns_topic_arns
  dimensions = {
    DBInstanceIdentifier = var.database_identifiers[count.index]
  }
}

resource "aws_cloudwatch_metric_alarm" "db_storage" {
  count               = length(var.database_identifiers)
  alarm_name          = "${var.project}-${var.environment}-db-${var.database_identifiers[count.index]}-free-storage"
  comparison_operator = "LessThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = local.db_allocated_storage_in_bytes * 0.1
  alarm_description   = "Alert when the DB free storage <== 10% of the overall storage"
  alarm_actions       = var.sns_topic_arns
  dimensions = {
    DBInstanceIdentifier = var.database_identifiers[count.index]
  }
}

resource "aws_cloudwatch_metric_alarm" "db_read" {
  count               = length(var.database_identifiers)
  alarm_name          = "${var.project}-${var.environment}-db-${var.database_identifiers[count.index]}-readlatency"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "ReadLatency"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 0.25
  alarm_description   = "Alert when DB Read Latency >= 0.25"
  alarm_actions       = var.sns_topic_arns
  dimensions = {
    DBInstanceIdentifier = var.database_identifiers[count.index]
  }
}

resource "aws_cloudwatch_metric_alarm" "db_write" {
  count               = length(var.database_identifiers)
  alarm_name          = "${var.project}-${var.environment}-db-${var.database_identifiers[count.index]}-writelatency"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "ReadLatency"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 0.25
  alarm_description   = "Alert when DB Write Latency >= 0.25"
  alarm_actions       = var.sns_topic_arns
  dimensions = {
    DBInstanceIdentifier = var.database_identifiers[count.index]
  }
}

resource "aws_cloudwatch_metric_alarm" "db_network_receive" {
  count               = length(var.database_identifiers)
  alarm_name          = "${var.project}-${var.environment}-db-${var.database_identifiers[count.index]}-network-receive-throughput"
  comparison_operator = "LessThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "NetworkReceiveThroughput"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "Alert when DB NetworkReceiveThroughput <= 0"
  dimensions = {
    DBInstanceIdentifier = var.database_identifiers[count.index]
  }
}

resource "aws_cloudwatch_metric_alarm" "db_network_transmit" {
  count               = length(var.database_identifiers)
  alarm_name          = "${var.project}-${var.environment}-db-${var.database_identifiers[count.index]}-network-transmit-throughput"
  comparison_operator = "LessThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "NetworkTransmitThroughput"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "Alert when DB NetworkTransmitThroughput <= 0"
  dimensions = {
    DBInstanceIdentifier = var.database_identifiers[count.index]
  }
}

resource "aws_cloudwatch_composite_alarm" "db_network" {
  count               = length(var.database_identifiers)
  alarm_name        = "${var.project}-${var.environment}-db-${var.database_identifiers[count.index]}-network"
  alarm_description = "Alert when there is no DB Network"

  alarm_actions = var.sns_topic_arns

  alarm_rule = "ALARM(${aws_cloudwatch_metric_alarm.db_network_receive[count.index].alarm_name}) AND ALARM(${aws_cloudwatch_metric_alarm.db_network_transmit[count.index].alarm_name})"
}

resource "aws_cloudwatch_metric_alarm" "db_read_iops" {
  count               = length(var.database_identifiers)
  alarm_name          = "${var.project}-${var.environment}-db-${var.database_identifiers[count.index]}-read-iops"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "ReadIOPS"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 2500
  alarm_description   = "Alert when DB Read IOPS >= 2500"
  alarm_actions       = var.sns_topic_arns
  dimensions = {
    DBInstanceIdentifier = var.database_identifiers[count.index]
  }
}

resource "aws_cloudwatch_metric_alarm" "db_write_iops" {
  count               = length(var.database_identifiers)
  alarm_name          = "${var.project}-${var.environment}-db-${var.database_identifiers[count.index]}-write-iops"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "WriteIOPS"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 2500
  alarm_description   = "Alert when DB Write IOPS >= 2500"
  alarm_actions       = var.sns_topic_arns
  dimensions = {
    DBInstanceIdentifier = var.database_identifiers[count.index]
  }
}


resource "aws_cloudwatch_metric_alarm" "redis_cpu" {
  count               = length(var.elasticache_cluster_names)
  alarm_name          = "${var.project}-${var.environment}-${var.elasticache_cluster_names[count.index]}-redis-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "EngineCPUUtilization"
  namespace           = "AWS/ElastiCache"
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alert when Redis CPU >= 80%"
  alarm_actions       = var.sns_topic_arns
  dimensions = {
    ReplicationGroupId = var.elasticache_cluster_names[count.index]
  }
}

resource "aws_cloudwatch_metric_alarm" "redis_memory" {
  count               = length(var.elasticache_cluster_names)
  alarm_name          = "${var.project}-${var.environment}-${var.elasticache_cluster_names[count.index]}-redis-memory-usage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "DatabaseMemoryUsageCountedForEvictPercentage"
  namespace           = "AWS/ElastiCache"
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alert when Redis Memory >= 80%"
  alarm_actions       = var.sns_topic_arns
  dimensions = {
    ReplicationGroupId = var.elasticache_cluster_names[count.index]
  }
}

resource "aws_cloudwatch_metric_alarm" "error_rate" {
  count               = length(var.alb_arn_suffixes)
  alarm_name          = "${var.project}-${var.environment}-${var.alb_arn_suffixes[count.index]}-error-rate"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 0.1
  alarm_description   = "Request error rate has exceeded 0.1%"
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
        LoadBalancer = var.alb_arn_suffixes[count.index]
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
        LoadBalancer = var.alb_arn_suffixes[count.index]
      }
    }
  }
}
