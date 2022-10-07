variable "fivetran_group_id" {
  type        = string
  description = "Also know as external_id. Understand the group concept here: https://fivetran.com/docs/getting-started/powered-by-fivetran#createagroupusingtheui"
}

variable "fivetran_aws_account_id" {
  type        = string
  default     = "834469178297" # the default aws account_id for fivetrans
  description = "Fivetran AWS account ID. We need to allow this account to access our lambda function."
}
