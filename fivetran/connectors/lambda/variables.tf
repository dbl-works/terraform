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

variable "fivetran_group_id" {
  type        = string
  description = "Also know as external_id. Understand the group concept here: https://fivetran.com/docs/getting-started/powered-by-fivetran#createagroupusingtheui"
}

variable "fivetran_aws_account_id" {
  type        = string
  default     = "834469178297" # the default aws account_id for fivetrans
  description = "Fivetran AWS account ID. We need to allow this account to access our lambda function."
}

variable "aws_region_code" {
  type        = string
  default     = "eu-central-1"
  description = "lambda's aws region"
}

variable "lambda_role_arn" {
  type        = string
  default     = null
  description = "Lambda role created for connecting the fivetran and lambda. Reuse the same role if you already have it created. Refer to the docs here: https://fivetran.com/docs/functions/aws-lambda/setup-guide#createiamrole"
}

variable "lambda_role_name" {
  type        = string
  default     = null
  description = "compulsory if user pass a lambda_role_arn and would also add the "
}

variable "policy_arns_for_lambda" {
  type        = list(string)
  default     = []
  description = "compulsory if user pass a lambda_role_arn and would also add the "
}

variable "service_name" {
  type        = string
  description = "connector name shown on Fivetran UI, i.e. (service_name)_(project)_(env)_(aws_region_code)"
  default     = null
}

variable "project" {
  type        = string
  description = "connector name shown on Fivetran UI, i.e. (service_name)_(project)_(env)_(aws_region_code)"
  default     = null
}

variable "environment" {
  type        = string
  description = "connector name shown on Fivetran UI, i.e. (service_name)_(project)_(env)_(aws_region_code)"
  default     = null
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
  default = {}
}
