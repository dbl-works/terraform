variable "fivetran_group_id" {
  type        = string
  description = "Also know as external_id. Understand the group concept here: https://fivetran.com/docs/getting-started/powered-by-fivetran#creategroupusingtheui"
}

variable "fivetran_aws_account_id" {
  type    = string
  default = "834469178297" # the default aws account_id for fivetrans
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
    serviceName      = string
    clusterName      = string
    loadBalancerName = string
    projectName      = string // Do not include any special characters. This value would be passed into the table
    environment      = string // Do not include any special characters. This value would be passed into the table
  }))
}
