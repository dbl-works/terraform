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
  description = "Priority for the AllowedDomainsRule. Set higher than block rules so they evaluate after them."
  type        = number
  default     = 1
}

variable "waf_rules" {
  description = "List of WAF rules to include in the Web ACL. Supports byte_match and managed_rule_group rule types."
  type = list(object({
    name     = string
    priority = number

    # Rule type: "byte_match", "managed_rule_group", "and_statement", or "or_statement"
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
    managed_rule_group_name = optional(string)       # e.g., "AWSManagedRulesCommonRuleSet"
    vendor_name             = optional(string, "AWS")
    excluded_rules          = optional(list(string), []) # Rules to exclude (set to COUNT), e.g., ["NoUserAgent_HEADER"]

    # For and_statement rules (byte_match only)
    and_statements = optional(list(object({
      field_to_match        = optional(string, "header") # "header" or "uri_path"
      header_name           = optional(string)           # Required when field_to_match = "header"
      match_value           = string                     # The value to match
      positional_constraint = optional(string, "EXACTLY")
      text_transformation   = optional(string, "NONE")
      negate                = optional(bool, false)      # Wraps the statement in not_statement
    })), [])

    # For or_statement rules (byte_match only)
    # Also used by and_statement rules to inject a single OR group.
    or_statements = optional(list(object({
      field_to_match        = optional(string, "header") # "header" or "uri_path"
      header_name           = optional(string)           # Required when field_to_match = "header"
      match_value           = string                     # The value to match
      positional_constraint = optional(string, "EXACTLY")
      text_transformation   = optional(string, "NONE")
      negate                = optional(bool, false)      # Wraps the statement in not_statement
    })), [])

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

  validation {
    condition = alltrue([
      for rule in var.waf_rules :
      !(try(rule.rule_type, null) == "or_statement" && length(try(rule.or_statements, [])) < 2)
    ])
    error_message = "Rules with rule_type = \"or_statement\" must include at least two or_statements."
  }
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
      match_value = try(coalesce(rule.match_value, rule.header_value), null)
    })
  ]
}
