resource "aws_wafv2_web_acl" "default-web-acl" {
  count = var.enable_waf ? 1 : 0

  name  = "default-web-acl"
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
    metric_name                = "default-web-acl"
    sampled_requests_enabled   = true
  }

  tags = {
    Name        = "default-web-acl"
    Environment = var.environment
    Project     = var.project
  }
}
