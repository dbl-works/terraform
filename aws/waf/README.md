# WAF

This module creates a WAF with rules. It will by default add `AWSManagedRulesCommonRuleSet`.

If you pass allowed domain names, it will add a rule to only allow traffic from those domains.

The WAF is regional, so it can be associated with all ALBs from one region (regardless of the environment).

**Notes**:

* Up to 50 ALBs can be attached to a single WebACL.
* up to 100 Amazon CloudFront distributions, AWS AppSync GraphQL APIs, or Amazon API Gateway REST APIs can be associated with a single WebACL.
* Any resource can only be attached to exactly one WebACL.
* Maximum number of requests per second per web ACL: 25k

Find more limites [here](https://docs.aws.amazon.com/waf/latest/developerguide/limits.html).

## Usage

```hcl
module "waf" {
  source = "github.com/dbl-works/terraform//aws/waf?ref=main"

  project = local.project
  region  = local.region # or region_name

  # NOTE: all subdomains are permitted
  permitted_domain_names = [
    "example.com",
    "example.cloud",
  ]

  waf_rules = [
    # AWS Managed Rule Groups
    {
      name                    = "AWSManagedRulesCommonRuleSet"
      priority                = 1
      rule_type               = "managed_rule_group"
      action_type             = "NONE" # Use "COUNT" to only count matches without blocking
      managed_rule_group_name = "AWSManagedRulesCommonRuleSet"
    },
    {
      name                    = "AWSManagedRulesKnownBadInputsRuleSet"
      priority                = 2
      rule_type               = "managed_rule_group"
      action_type             = "NONE"
      managed_rule_group_name = "AWSManagedRulesKnownBadInputsRuleSet"
    },

    # AWS Managed Rule Group with override
    # Rules listed in `excluded_rules` keep their rule logic but override the default BLOCK action to COUNT
    {
      name                    = "AWSManagedRulesCommonRuleSet"
      priority                = 3
      rule_type               = "managed_rule_group"
      action_type             = "NONE"
      managed_rule_group_name = "AWSManagedRulesCommonRuleSet"
      excluded_rules          = ["NoUserAgent_HEADER"]
    },

    # Block exploit file extensions via URI path matching
    {
      name                  = "BlockPHP"
      priority              = 10
      rule_type             = "byte_match"
      action_type           = "BLOCK"
      field_to_match        = "uri_path"
      match_value           = ".php"
      positional_constraint = "ENDS_WITH"
      text_transformation   = "LOWERCASE"
    },

    # Header-based rules
    {
      name                  = "AllowCloudflare"
      priority              = 50
      rule_type             = "byte_match"
      action_type           = "ALLOW"
      field_to_match        = "header"
      header_name           = "X-Custom-Header"
      match_value           = "your-secret-value"
      positional_constraint = "EXACTLY"
      text_transformation   = "NONE"
    },

    # Block internal-api unless Origin matches its environment domain
    {
      name        = "BlockInternalApiBadOriginStaging"
      priority    = 20
      rule_type   = "and_statement"
      action_type = "BLOCK"
      and_statements = [
        {
          field_to_match        = "header"
          header_name           = "host"
          match_value           = "internal-api.example.staing"
          positional_constraint = "EXACTLY"
        },
        {
          field_to_match        = "header"
          header_name           = "origin"
          match_value           = ".example.staing"
          positional_constraint = "ENDS_WITH"
          text_transformation   = "LOWERCASE"
          negate                = true
        },
      ]
    },
    {
      name        = "BlockInternalApiBadOriginProd"
      priority    = 21
      rule_type   = "and_statement"
      action_type = "BLOCK"
      and_statements = [
        {
          field_to_match        = "header"
          header_name           = "host"
          match_value           = "internal-api.example.prod"
          positional_constraint = "EXACTLY"
        },
        {
          field_to_match        = "header"
          header_name           = "origin"
          match_value           = ".example.prod"
          positional_constraint = "ENDS_WITH"
          text_transformation   = "LOWERCASE"
          negate                = true
        },
      ]
    },
  ]
}
```

The module outputs the WAF ARN. Pass this ARN to the ECS module to associate the WAF with the ALB.

## Rule Types

The `waf_rules` variable supports four rule types:

Notes:
- `rule_type` is optional. If omitted, it defaults to `"byte_match"` unless `managed_rule_group_name` is set, in which case it is treated as `"managed_rule_group"`.
- `header_value` is accepted as a legacy alias for `match_value`.

### 1. Managed Rule Groups (`rule_type = "managed_rule_group"`)

AWS-managed rule sets that provide protection against common threats:

| Rule Group | Description |
|-----------|-------------|
| `AWSManagedRulesCommonRuleSet` | General web application protection |
| `AWSManagedRulesKnownBadInputsRuleSet` | Log4j, Java deserialization, and other known exploits |
| `AWSManagedRulesSQLiRuleSet` | SQL injection protection |
| `AWSManagedRulesLinuxRuleSet` | Linux-specific attacks (LFI, command injection) |
| `AWSManagedRulesUnixRuleSet` | Unix-specific attacks |
| `AWSManagedRulesPHPRuleSet` | PHP-specific attacks |

For managed rules, use `action_type`:
- `"NONE"` - Respect the rule group's default actions (block)
- `"COUNT"` - Override all rules to count only (useful for testing)

### 2. Byte Match Rules (`rule_type = "byte_match"`)

Custom rules that match specific patterns in requests:

| Field | Description |
|-------|-------------|
| `field_to_match` | `"header"` or `"uri_path"` |
| `header_name` | Header name (required when `field_to_match = "header"`) |
| `match_value` | The string to match against |
| `positional_constraint` | `"EXACTLY"`, `"STARTS_WITH"`, `"ENDS_WITH"`, `"CONTAINS"` |
| `text_transformation` | `"NONE"`, `"LOWERCASE"`, `"URL_DECODE"`, etc. |

For byte match rules, use `action_type`:
- `"ALLOW"` - Allow matching requests
- `"BLOCK"` - Block matching requests
- `"COUNT"` - Count but don't block

### 3. And Statement Rules (`rule_type = "and_statement"`)

Combine multiple byte match statements with AND. Each statement can optionally be negated.

Example: block `internal-api` unless Origin ends with your domains. Use OR for host matching and AND + NOT for Origin:

```hcl
{
  name        = "BlockInternalApiBadOrigin"
  priority    = 20
  rule_type   = "and_statement"
  action_type = "BLOCK"
  or_statements = [
    {
      field_to_match        = "header"
      header_name           = "host"
      match_value           = "internal-api.example.cloud"
      positional_constraint = "EXACTLY"
    },
    {
      field_to_match        = "header"
      header_name           = "host"
      match_value           = "internal-api.example.earth"
      positional_constraint = "EXACTLY"
    },
  ]
  and_statements = [
    {
      field_to_match        = "header"
      header_name           = "origin"
      match_value           = ".example.cloud"
      positional_constraint = "ENDS_WITH"
      text_transformation   = "LOWERCASE"
      negate                = true
    },
    {
      field_to_match        = "header"
      header_name           = "origin"
      match_value           = ".example.earth"
      positional_constraint = "ENDS_WITH"
      text_transformation   = "LOWERCASE"
      negate                = true
    },
  ]
}
```

Note: missing `Origin` will not match the byte match statements, so the negated statements evaluate to true and the request is blocked (as intended).

### 4. Or Statement Rules (`rule_type = "or_statement"`)

Match any of the provided byte match statements:

```hcl
{
  name        = "AllowHealthcheckPaths"
  priority    = 5
  rule_type   = "or_statement"
  action_type = "ALLOW"
  or_statements = [
    {
      field_to_match        = "uri_path"
      match_value           = "/health"
      positional_constraint = "EXACTLY"
    },
    {
      field_to_match        = "uri_path"
      match_value           = "/metrics"
      positional_constraint = "EXACTLY"
    },
  ]
}
```


## Rules

See [waf-rules](https://docs.aws.amazon.com/waf/latest/developerguide/waf-rules.html).

See [waf-oversize-request-components](https://docs.aws.amazon.com/waf/latest/developerguide/waf-oversize-request-components.html)

* Body and JSON Body - For Application Load Balancer and AWS AppSync, AWS WAF can inspect the first 8 KB of the body of a request. For CloudFront, API Gateway, Amazon Cognito, App Runner, and Verified Access, by default, AWS WAF can inspect the first 16 KB, and you can increase the limit up to 64 KB in your web ACL configuration.
* Headers - AWS WAF can inspect at most the first 8 KB (8,192 bytes) of the request headers and at most the first 200 headers. The content is available for inspection by AWS WAF up to the first limit reached.
* Cookies - AWS WAF can inspect at most the first 8 KB (8,192 bytes) of the request cookies and at most the first 200 cookies. The content is available for inspection by AWS WAF up to the first limit reached.
