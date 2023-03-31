variable "bastion_aws_account_id" {
  type        = string
  description = "aws account id for the bastion account."
}

variable "max_session_duration" {
  type        = number
  description = "Maximum session duration (in seconds) that you want to set for the specified role."
  default     = 3600
}

variable "policy_name" {
  type = string
}

variable "aws_role_name" {
  type        = string
  description = "assume-role"
}
