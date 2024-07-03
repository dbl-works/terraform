locals {
  waf_acl_name = "${var.project}-${var.environment}-alb-waf-acl"
}

resource "aws_wafv2_web_acl" "alb" {
  count = var.enable_waf ? 1 : 0

  name  = local.waf_acl_name
  scope = var.waf_scope

  default_action {
    block {}
  }

  dynamic "rule" {
    for_each = var.waf_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      dynamic "action" {
        for_each = rule.value.action_type == "ALLOW" ? [1] : []
        content {
          allow {}
        }
      }

      dynamic "action" {
        for_each = rule.value.action_type == "BLOCK" ? [1] : []
        content {
          block {}
        }
      }

      dynamic "action" {
        for_each = rule.value.action_type == "COUNT" ? [1] : []
        content {
          count {}
        }
      }

      statement {
        dynamic "byte_match_statement" {
          for_each = rule.value.header_name != null ? [1] : []
          content {
            search_string = rule.value.header_value
            field_to_match {
              single_header {
                name = rule.value.header_name
              }
            }
            text_transformation {
              priority = 0
              type     = rule.value.text_transformation
            }
            positional_constraint = rule.value.positional_constraint
          }
        }

        dynamic "managed_rule_group_statement" {
          for_each = rule.value.name == "AWSManagedRulesCommonRuleSet" ? [1] : []
          content {
            name        = "AWSManagedRulesCommonRuleSet"
            vendor_name = "AWS"
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

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = local.waf_acl_name
    sampled_requests_enabled   = true
  }

  tags = {
    Name        = local.waf_acl_name
    Environment = var.environment
    Project     = var.project
  }
}
