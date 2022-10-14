variable "response_time_threshold" {
  type        = number
  default     = 0.10
  description = "Threshold time that the server took to send a response."
}

variable "duration_threshold" {
  type        = number
  default     = 0.12
  description = "Total request duration including all downstream calls."
}

variable "region" {
  type        = string
  default     = "eu-central-1"
  description = "Region identifier"
}

variable "account_id" {
  type        = string
  description = "AWS account ID for the IAM access rules"
}

variable "name" {
  type        = string
  default     = null
  description = "custom name if the auto-generated one is not desired"
}
