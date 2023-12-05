variable "user_name" {
  type        = string
  default     = "deploy-bot"
  description = "The name of the AWS IAM user whose credentials are used to perform AWS actions within your CircleCI workflows."
}

variable "context_name" {
  type        = string
  default     = null
  description = "The name of the CircleCI context where AWS credentials will be stored"
}

variable "circle_ci_organization_id" {
  type        = string
  description = "The unique identifier for your CircleCI organization. Read here for more info: https://circleci.com/docs/introduction-to-the-circleci-web-app/#organization-settings"
}

variable "token_rotation_interval_days" {
  type        = number
  default     = 183
  description = "The number of days after which the token rotation will occur"
}

variable "project" {
  type        = string
  description = "Used for resources naming"
}

# https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html
variable "timeout" {
  type        = number
  description = "The amount of time that Lambda allows a function to run before stopping it."
  default     = 900
}

variable "memory_size" {
  type        = number
  description = "The amount of memory that your function has access to."
  default     = 128
}
