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

variable "allowed_domains_rule_priority" {
  description = "Priority for the AllowedDomainsRule. Set higher than block rules so they evaluate first."
  type        = number
  default     = 1
}

variable "waf_rules" {
  description = "List of WAF rules to include in the Web ACL. Supports byte_match and managed_rule_group rule types."
  type = list(object({
    name     = string
    priority = number

    # Rule type: "byte_match" or "managed_rule_group"
    rule_type = optional(string)

    # Action: ALLOW, BLOCK, COUNT for byte_match rules
    # For managed_rule_group: use "NONE" to respect rule group defaults, or "COUNT" to override all to count
    action_type = string

    # For byte_match rules
    field_to_match        = optional(string, "header") # "header" or "uri_path"
    header_name           = optional(string)           # Required when field_to_match = "header"
    match_value           = optional(string)           # The value to match
    header_value          = optional(string)           # Deprecated: use match_value
    positional_constraint = optional(string, "EXACTLY")
    text_transformation   = optional(string, "NONE")

    # For managed_rule_group rules
    managed_rule_group_name = optional(string) # e.g., "AWSManagedRulesCommonRuleSet"
    vendor_name             = optional(string, "AWS")
  }))
  default = [
    {
      name                    = "AWSManagedRulesCommonRuleSet"
      priority                = 1
      rule_type               = "managed_rule_group"
      action_type             = "COUNT"
      managed_rule_group_name = "AWSManagedRulesCommonRuleSet"
    }
  ]
}

locals {
  # 1-128 characters, a-z, A-Z, 0-9, and _ (underscore)
  # unique within the scope of the resource
  #   i.e. unique per REGION if scope is REGIONAL
  #        unique per ACCOUNT if scope is CLOUDFRONT
  waf_acl_name = "${var.project}-${var.region}-waf-acl"

  waf_rules_normalized = [
    for rule in var.waf_rules : merge(rule, {
      rule_type = coalesce(
        rule.rule_type,
        rule.managed_rule_group_name != null ? "managed_rule_group" : null,
        "byte_match"
      )
      match_value = coalesce(rule.match_value, rule.header_value)
    })
  ]
}
