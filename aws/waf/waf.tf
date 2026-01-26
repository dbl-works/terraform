resource "aws_wafv2_web_acl" "main" {
  name        = local.waf_acl_name
  scope       = "REGIONAL" # or "CLOUDFRONT", but we have 1 ALB per cluster
  description = "Web ACL for ${var.project} in ${var.region}."

  default_action {
    block {}
  }

  dynamic "rule" {
    for_each = var.waf_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority + 1 # prio must be unique. Hardcoded rules: see below

      # Action block for byte_match rules
      dynamic "action" {
        for_each = rule.value.rule_type == "byte_match" ? [1] : []

        content {
          dynamic "allow" {
            for_each = rule.value.action_type == "ALLOW" ? [1] : []
            content {}
          }

          dynamic "block" {
            for_each = rule.value.action_type == "BLOCK" ? [1] : []
            content {}
          }

          dynamic "count" {
            for_each = rule.value.action_type == "COUNT" ? [1] : []
            content {}
          }
        }
      }

      # Override action for managed_rule_group rules
      dynamic "override_action" {
        for_each = rule.value.rule_type == "managed_rule_group" ? [1] : []

        content {
          dynamic "none" {
            for_each = rule.value.action_type == "NONE" ? [1] : []
            content {}
          }
          dynamic "count" {
            for_each = rule.value.action_type == "COUNT" ? [1] : []
            content {}
          }
        }
      }

      statement {
        # Byte match on header
        dynamic "byte_match_statement" {
          for_each = rule.value.rule_type == "byte_match" && coalesce(rule.value.field_to_match, "header") == "header" ? [1] : []
          content {
            search_string = rule.value.match_value
            field_to_match {
              single_header {
                name = rule.value.header_name
              }
            }
            text_transformation {
              priority = 0
              type     = coalesce(rule.value.text_transformation, "NONE")
            }
            positional_constraint = coalesce(rule.value.positional_constraint, "EXACTLY")
          }
        }

        # Byte match on URI path
        dynamic "byte_match_statement" {
          for_each = rule.value.rule_type == "byte_match" && coalesce(rule.value.field_to_match, "header") == "uri_path" ? [1] : []
          content {
            search_string = rule.value.match_value
            field_to_match {
              uri_path {}
            }
            text_transformation {
              priority = 0
              type     = coalesce(rule.value.text_transformation, "NONE")
            }
            positional_constraint = coalesce(rule.value.positional_constraint, "EXACTLY")
          }
        }

        # Managed rule group
        dynamic "managed_rule_group_statement" {
          for_each = rule.value.rule_type == "managed_rule_group" ? [1] : []
          content {
            name        = rule.value.managed_rule_group_name
            vendor_name = coalesce(rule.value.vendor_name, "AWS")
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.name
        sampled_requests_enabled   = true
      }
    }
  }

  rule {
    name     = "AllowedDomainsRule"
    priority = 1 # Adjust the priority accordingly

    action {
      allow {}
    }

    statement {
      or_statement {
        dynamic "statement" {
          for_each = var.permitted_domain_names
          content {
            byte_match_statement {
              search_string = statement.value
              field_to_match {
                single_header {
                  name = "host"
                }
              }
              text_transformation {
                priority = 0
                type     = "NONE"
              }
              # must use "exact match". If you use e.g. "ENDS_WITH" then "evil-example.com" matches "example.com"
              positional_constraint = "EXACTLY"
            }
          }
        }

        dynamic "statement" {
          for_each = var.permitted_domain_names
          content {
            byte_match_statement {
              search_string = ".${statement.value}"
              field_to_match {
                single_header {
                  name = "host"
                }
              }
              text_transformation {
                priority = 0
                type     = "NONE"
              }
              positional_constraint = "ENDS_WITH"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "allowed-domains-rule"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = local.waf_acl_name
    sampled_requests_enabled   = true
  }

  tags = {
    Name        = local.waf_acl_name
    Environment = "regional-${var.region}"
    Project     = var.project
  }
}
