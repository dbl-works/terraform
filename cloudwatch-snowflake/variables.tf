variable "fivetran_group_id" {
  type        = string
  description = "Also know as external_id. Understand the group concept here: https://fivetran.com/docs/getting-started/powered-by-fivetran#createagroupusingtheui"
}

variable "lambda_role_arn" {
  type        = string
  default     = null
  description = "Lambda role created for connecting the fivetran and lambda. Reuse the same role if you already have it created. Refer to the docs here: https://fivetran.com/docs/functions/aws-lambda/setup-guide#createiamrole"
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

variable "organisation" {
  type        = string
  description = "connector name shown on Fivetran UI, i.e. cloudwatch_metrics_(organisation)"
}

variable "tracked_resources_data" {
  type = list(object({
    serviceName      = string // ecs service name. eg. aws_ecs_service => name
    clusterName      = string // ecs cluster name. eg. aws_ecs_cluster => name
    loadBalancerName = string // load balancer arn suffix. eg. aws_lb => arn_suffix
    projectName      = string // Do not include any special characters. This value will be passed into the snowflake table under the project column
    environment      = string // Do not include any special characters. This value will be passed into the snowflake table under the environment column
  }))
}
