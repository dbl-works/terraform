variable "region" {
  type = string
}

variable "dashboard_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "database_name" {
  type = string
}

variable "alb_arn_suffix" {
  type = string
}

variable "elasticache_cluster_name" {
  type = string
}

variable "period" {
  type    = number
  default = 60
}

variable "alarm_period" {
  type    = number
  default = 300
}

variable "alarm_evaluation_periods" {
  type    = number
  default = 1
}
