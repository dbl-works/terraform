# Terraform Module: Cloudflare Zero Trust

This module puts a Cloudflare Access login in front of one or more hostnames.
Users log in with an email One-time PIN or with an identity provider that you configure in the Zero Trust dashboard.
Your application receives only requests from users that match an allow policy. You do not build user management.

The module creates:

- One Access application per hostname
- One allow policy per application, based on email addresses and/or email domains
- Optionally the email One-time PIN identity provider
- Optionally a service token and a matching policy per application, for CI and scripts

## Pre-setup

1. Create a Zero Trust team domain once per account: Zero Trust dashboard -> Settings -> Custom Pages -> Team domain.
2. Find the account ID: Cloudflare dashboard -> any zone -> Overview -> API section.
3. Give the API token these permissions:
    - Account - Access: Apps and Policies: Edit
    - Account - Access: Service Tokens: Edit
    - Account - Access: Organizations, Identity Providers, and Groups: Edit

```shell
export CLOUDFLARE_API_TOKEN=xxx
```

## Protect the origin

Access checks requests at the Cloudflare edge only. A request that goes to the origin directly skips the check.
Make sure the origin accepts requests from Cloudflare only:

- For an ALB or NLB in front of ECS, enable `authenticated_origin_pull` in the [zone](../zone/README.md) module and use the [alb-mtls](../../aws/alb-mtls/README.md) module.
- For a static site in S3, keep the bucket private and serve it through the Cloudflare worker that the zone module routes.
- Optionally verify the `Cf-Access-Jwt-Assertion` header in the application against the `application_auds` output.

## Usage

```terraform
module "cloudflare_zero_trust" {
  source = "github.com/dbl-works/terraform//cloudflare/zero-trust?ref=v2026.09.05"

  account_id  = "0123456789abcdef0123456789abcdef"
  project     = "someproject"
  environment = "staging"

  applications = {
    admin = {
      hostname              = "admin.example.com"
      allowed_email_domains = ["example.com"]
    }
    reports = {
      hostname              = "reports.example.com"
      session_duration      = "12h"
      allowed_emails        = ["alice@example.com", "bob@example.com"]
      service_token_enabled = true
    }
  }

  # optional
  one_time_pin_enabled = true
}
```

## Service tokens

A service token replaces the interactive login for machines. Send the two headers with each request:

```shell
curl https://reports.example.com/export \
  -H "CF-Access-Client-Id: $(terraform output -json service_token_client_ids | jq -r .reports)" \
  -H "CF-Access-Client-Secret: $(terraform output -json service_token_client_secrets | jq -r .reports)"
```

Service tokens expire after one year. Terraform recreates a token when it expires and you apply again.

## Cost

Cloudflare Zero Trust is free for up to 50 users per account.
