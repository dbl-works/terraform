# Terraform Module: Cloudflare Zero Trust

This module puts a Cloudflare Access login in front of one or more hostnames.
Users log in with an email One-time PIN. Your application does not manage users.

The module creates:

- One Access application for each hostname
- One allow policy for each application, by email address or email domain
- The email One-time PIN identity provider (optional)
- A service token for machine access (optional)

## Pre-setup

1. Create a Zero Trust team domain: Zero Trust dashboard -> Settings -> Custom Pages.
2. Copy the account ID from the zone overview page.
3. Create an API token with these permissions:
    - Account - Access: Apps and Policies: Edit
    - Account - Access: Service Tokens: Edit
    - Account - Access: Organizations, Identity Providers, and Groups: Edit

```shell
export CLOUDFLARE_API_TOKEN=xxx
```

## Protect the origin

Access checks requests at the Cloudflare edge only. Make sure the origin accepts requests from Cloudflare only.

- ECS behind an ALB: enable `authenticated_origin_pull` in the [zone](../zone/README.md) module and use [alb-mtls](../../aws/alb-mtls/README.md).
- Static site in S3: keep the bucket private and serve it through the Cloudflare worker.

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
      allowed_emails        = ["alice@example.com"]
      service_token_enabled = true
    }
  }

  # optional
  one_time_pin_enabled = true
}
```

## Service tokens

Send these two headers to skip the interactive login:

```shell
curl https://reports.example.com/export \
  -H "CF-Access-Client-Id: <client_id>" \
  -H "CF-Access-Client-Secret: <client_secret>"
```

Read both values from the `service_token_client_ids` and `service_token_client_secrets` outputs.
Service tokens expire after one year. Apply again to create a new token.

NOTE: Cloudflare Zero Trust is free for up to 50 users.
