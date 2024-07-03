locals {
  # 1-128 characters, a-z, A-Z, 0-9, and _ (underscore)
  # unique within the scope of the resource
  #   i.e. unique per REGION if scope is REGIONAL
  #        unique per ACCOUNT if scope is CLOUDFRONT
  waf_acl_name = "${var.project}-${var.environment}-alb-waf-acl"
}

resource "aws_wafv2_web_acl_association" "alb_waf" {
  count = var.enable_waf ? 1 : 0

  resource_arn = aws_alb.alb.arn
  web_acl_arn  = aws_wafv2_web_acl.alb[0].arn
}

resource "aws_wafv2_web_acl" "alb" {
  count = var.enable_waf ? 1 : 0

  name  = local.waf_acl_name
  scope = "REGIONAL" # or "CLOUDFRONT", but we have 1 ALB per cluster

  default_action {
    block {}
  }

  dynamic "rule" {
    for_each = var.waf_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      dynamic "action" {
        for_each = rule.value.name != "AWSManagedRulesCommonRuleSet" ? [1] : []

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

      dynamic "override_action" {
        # TODO: We should match the rule set name here
        for_each = rule.value.name == "AWSManagedRulesCommonRuleSet" ? [1] : []

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

  dynamic "rule" {
    for_each = [1]
    content {
      name     = "RequireSpecificHost"
      priority = 1 # Adjust the priority accordingly

      action {
        allow {}
      }

      statement {
        byte_match_statement {
          search_string = var.domain_name
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

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "RequireSpecificHost"
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
