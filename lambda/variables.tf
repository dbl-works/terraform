variable "subnet_ids" {
  type        = list(string)
  description = "Subnets the lambdas are allowed to use to access resources in the VPC."
}

variable "security_group_ids" {
  type        = list(string)
  description = "To allow or deny specific access to resources in the VPC."
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "function_name" {
  type        = string
  description = "A unique identifier for the function."
}

# https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime
variable "runtime" {
  type        = string
  description = "The runtime environment for the Lambda function."
  default     = "nodejs16.x"
}

variable "secrets_and_kms_arns" {
  type        = list(string)
  description = "Grant access to the lambda function to Secrets and KMS keys"
  default     = []
}

variable "source_dir" {
  type        = string
  description = "Path to the directory containing the lambda function code."
  default     = null
}

# https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html
variable "timeout" {
  type        = number
  description = "The amount of time that Lambda allows a function to run before stopping it."
  default     = 900
}

variable "handler" {
  type        = string
  description = "Function entrypoint in your code."
  default     = "index.handler"
}

variable "memory_size" {
  type        = number
  description = "The amount of memory that your function has access to."
  default     = 128
}
