locals {
  default_waf_acl_name = "${var.project}-${var.environment}-default-web-acl"

}
resource "aws_wafv2_web_acl" "default-web-acl" {
  count = var.enable_waf && var.waf_acl_arn == "default-web-acl" ? 1 : 0

  name  = local.default_waf_acl_name
  scope = var.waf_scope

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = local.default_waf_acl_name
    sampled_requests_enabled   = true
  }

  tags = {
    Name        = local.default_waf_acl_name
    Environment = var.environment
    Project     = var.project
  }
}
