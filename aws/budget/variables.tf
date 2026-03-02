variable "project" {
  description = "Project name, used for tagging and naming"
  type        = string
}

variable "environment" {
  description = "Environment name, used for tagging and naming"
  type        = string
}

variable "budget_name" {
  description = "The name of the budget. Defaults to $${project}-$${environment}-budget"
  type        = string
  default     = ""
}

variable "budget_type" {
  description = "Whether this budget tracks monetary cost or usage"
  type        = string
  default     = "COST"
}

variable "limit_amount" {
  description = "The amount of cost or usage being measured for a budget (in limit_unit currency)"
  type        = string
}

variable "limit_unit" {
  description = "The unit of measurement used for the budget forecast, actual spend, or budget threshold, such as dollars or GB"
  type        = string
  default     = "EUR"
}

variable "time_unit" {
  description = "The length of time until a budget resets the actual and forecasted spend. Valid values: MONTHLY, QUARTERLY, ANNUALLY"
  type        = string
  default     = "MONTHLY"
}

variable "time_period_start" {
  description = "The start of the time period covered by the budget. Format: YYYY-MM-DD_HH:MM. Defaults to start of current period if omitted."
  type        = string
  default     = null
}

variable "account_limit_amount" {
  description = "Optional: amount for a global account-wide budget (no tag filtering). Set to null to skip."
  type        = string
  default     = null
}

# Notifications
variable "subscriber_email_addresses" {
  description = "List of email addresses to notify (at least one required)"
  type        = list(string)
}

variable "subscriber_sns_topic_arns" {
  description = "List of SNS topic ARNs to notify"
  type        = list(string)
  default     = []
}

variable "actual_threshold_percentage" {
  description = "Threshold percentage for actual spend alerts"
  type        = number
  default     = 100
}

variable "forecasted_threshold_percentage" {
  description = "Threshold percentage for forecasted spend alerts"
  type        = number
  default     = 100
}
