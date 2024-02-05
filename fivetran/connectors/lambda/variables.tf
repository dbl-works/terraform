variable "fivetran_group_id" {
  type        = string
  description = "Also know as external_id. Understand the group concept here: https://fivetran.com/docs/getting-started/powered-by-fivetran#createagroupusingtheui"
}

variable "lambda_name" {
  type    = string
  default = null
}

variable "runtime" {
  type        = string
  description = "The runtime environment for the Lambda function, see https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime."
  default     = "nodejs20.x"
}

variable "timeout" {
  type    = number
  default = 900
}

variable "memory_size" {
  type        = number
  description = "The amount of memory that your function has access to."
  default     = 128
}

variable "lambda_source_dir" {
  type        = string
  description = "Path to the directory containing the lambda function code"
  default     = null
}

variable "lambda_output_path" {
  type        = string
  description = "Path to output the zipped lambda function code"
  default     = null
}

variable "aws_region_code" {
  type        = string
  default     = "eu-central-1"
  description = "lambda's aws region"
}

variable "lambda_role_arn" {
  type        = string
  description = "Lambda role created for connecting the fivetran and lambda. Reuse the same role if you already have it created. Refer to the docs here: https://fivetran.com/docs/functions/aws-lambda/setup-guide#createiamrole"
}

variable "service_name" {
  type        = string
  description = "connector name shown on Fivetran UI, i.e. (service_name)_(project)_(env)_(aws_region_code)"
  default     = null
}

variable "project" {
  type        = string
  description = "connector name shown on Fivetran UI, i.e. (service_name)_(project)_(env)_(aws_region_code)"
}

variable "environment" {
  type        = string
  description = "connector name shown on Fivetran UI, i.e. (service_name)_(project)_(env)_(aws_region_code)"
}

variable "connector_name" {
  type        = string
  description = "connector name shown on Fivetran UI. If not specified, it will be the combination of (service_name)_(project)_(env)_(aws_region_code)"
  default     = null
}

variable "script_env" {
  # type = {
  #   ENV_1 : "abc"
  #   ENV_2 : []
  # }
  type    = map(any)
  default = {}
}

variable "sync_frequency" {
  type        = string
  default     = "60" // min
  description = "The supported values are: 1, 5, 15, 30, 60, 120, 180, 360, 480, 720, 1440."
  validation {
    condition     = can(regex("^(1|5|15|30|60|120|180|360|480|720|1440)$", var.sync_frequency))
    error_message = "The supported values are: 1, 5, 15, 30, 60, 120, 180, 360, 480, 720, 1440."
  }
}
