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
  type = string
}

variable "tracked_resources_data" {
  type = list(object({
    serviceName      = string
    clusterName      = string
    metricName       = string
    projectName      = string
    loadBalancerName = string
  }))
}
