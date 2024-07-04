variable "project" {
  type = string
}

variable "region" {
  type        = string
  default     = null
  description = "Typically, we abbreviate the region for naming, e.g. 'us-east-1' is passed as 'us-east'."
}

variable "permitted_domain_names" {
  description = "Allowlisted domain names"
  type        = list(string)
  default     = []
}

variable "waf_rules" {
  description = "List of WAF rules to include in the Web ACL"
  type = list(object({
    name                  = string
    priority              = number
    action_type           = string # one of: ALLOW, BLOCK, COUNT
    header_name           = optional(string)
    header_value          = optional(string)
    positional_constraint = optional(string, "EXACTLY")
    text_transformation   = optional(string, "NONE")
  }))
  default = [
    {
      name                  = "AWSManagedRulesCommonRuleSet"
      priority              = 1
      action_type           = "COUNT"
      header_name           = null
      header_value          = null
      positional_constraint = "EXACTLY"
      text_transformation   = "NONE"
    }
  ]
}

locals {
  # 1-128 characters, a-z, A-Z, 0-9, and _ (underscore)
  # unique within the scope of the resource
  #   i.e. unique per REGION if scope is REGIONAL
  #        unique per ACCOUNT if scope is CLOUDFRONT
  waf_acl_name = "${var.project}-${var.region}-waf-acl"
}
