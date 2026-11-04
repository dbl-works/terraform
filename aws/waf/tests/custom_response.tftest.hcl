mock_provider "aws" {}

variables {
  project = "example"
  region  = "eu-central"

  permitted_domain_names = ["example.com"]

  custom_response_bodies = {
    unauthorized = {
      content      = "{\"errors\":[{\"code\":\"not_authorized\"}]}"
      content_type = "APPLICATION_JSON"
    }
  }
}

run "block_rule_returns_custom_response" {
  command = plan

  variables {
    waf_rules = [
      {
        name           = "BlockWithoutCredentials"
        priority       = 1
        action_type    = "BLOCK"
        field_to_match = "uri_path"
        match_value    = "/v2/"
        custom_response = {
          response_code            = 401
          custom_response_body_key = "unauthorized"
          response_headers         = { "x-blocked-by" = "waf" }
        }
      },
      {
        name           = "BlockPHP"
        priority       = 2
        action_type    = "BLOCK"
        field_to_match = "uri_path"
        match_value    = ".php"
      },
    ]
  }

  assert {
    condition     = one([for r in aws_wafv2_web_acl.main.rule : r.action[0].block[0].custom_response[0].response_code if r.name == "BlockWithoutCredentials"]) == 401
    error_message = "A BLOCK rule with custom_response must answer with its response_code."
  }

  assert {
    condition     = one([for r in aws_wafv2_web_acl.main.rule : r.action[0].block[0].custom_response[0].custom_response_body_key if r.name == "BlockWithoutCredentials"]) == "unauthorized"
    error_message = "A BLOCK rule with custom_response must reference its body key."
  }

  assert {
    condition     = one(flatten([for r in aws_wafv2_web_acl.main.rule : [for h in r.action[0].block[0].custom_response[0].response_header : "${h.name}=${h.value}"] if r.name == "BlockWithoutCredentials"])) == "x-blocked-by=waf"
    error_message = "A BLOCK rule with custom_response must send its response headers."
  }

  assert {
    condition     = one([for r in aws_wafv2_web_acl.main.rule : length(r.action[0].block[0].custom_response) if r.name == "BlockPHP"]) == 0
    error_message = "A BLOCK rule without custom_response must keep the default 403."
  }

  assert {
    condition     = one([for b in aws_wafv2_web_acl.main.custom_response_body : b.content_type if b.key == "unauthorized"]) == "APPLICATION_JSON"
    error_message = "The web ACL must define every body in custom_response_bodies."
  }
}

run "count_rule_ignores_custom_response" {
  command = plan

  variables {
    waf_rules = [
      {
        name           = "BlockWithoutCredentials"
        priority       = 1
        action_type    = "COUNT"
        field_to_match = "uri_path"
        match_value    = "/v2/"
        custom_response = {
          response_code            = 401
          custom_response_body_key = "unauthorized"
        }
      },
    ]
  }

  assert {
    condition     = one([for r in aws_wafv2_web_acl.main.rule : length(r.action[0].count) if r.name == "BlockWithoutCredentials"]) == 1
    error_message = "Switching a rule to COUNT must keep counting even when custom_response is set."
  }

  assert {
    condition     = one([for r in aws_wafv2_web_acl.main.rule : length(r.action[0].block) if r.name == "BlockWithoutCredentials"]) == 0
    error_message = "A COUNT rule must not render a block action."
  }
}
