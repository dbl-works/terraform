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
  source = "github.com/dbl-works/terraform//aws/aws/waf?ref=main"

  project = local.project
  region  = local.region # or region_name

  # NOTE: all subdomans are permitted
  permitted_domain_names = [
    "example.com",
    "example.cloud",
  ]

  waf_rules = [
    {
      name                  = "AllowCloudflare"
      priority              = 1
      action_type           = "ALLOW"
      header_name           = "X-Custom-Header"
      header_value          = "your-secret-value" # inject some secret to the headers in CF
      positional_constraint = "EXACTLY"
      text_transformation   = "NONE"
    },
    {
      name                  = "BlockOtherTraffic"
      priority              = 2
      action_type           = "BLOCK"
      header_name           = "X-Other-Header"
      header_value          = "block-value"
      positional_constraint = "CONTAINS"
      text_transformation   = "LOWERCASE"
    }
  ]
}
```

The module outputs the WAF ARN. Pass this ARN to the ECS module to associate the WAF with the ALB.

## Rules

See [waf-rules](https://docs.aws.amazon.com/waf/latest/developerguide/waf-rules.html).

See [waf-oversize-request-components](https://docs.aws.amazon.com/waf/latest/developerguide/waf-oversize-request-components.html)

* Body and JSON Body - For Application Load Balancer and AWS AppSync, AWS WAF can inspect the first 8 KB of the body of a request. For CloudFront, API Gateway, Amazon Cognito, App Runner, and Verified Access, by default, AWS WAF can inspect the first 16 KB, and you can increase the limit up to 64 KB in your web ACL configuration.
* Headers - AWS WAF can inspect at most the first 8 KB (8,192 bytes) of the request headers and at most the first 200 headers. The content is available for inspection by AWS WAF up to the first limit reached.
* Cookies - AWS WAF can inspect at most the first 8 KB (8,192 bytes) of the request cookies and at most the first 200 cookies. The content is available for inspection by AWS WAF up to the first limit reached.
