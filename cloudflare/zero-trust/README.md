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
3. Create an API token with the permissions in the table below.

| Scope | Permission | Access level |
|---|---|---|
| Account | Access: Apps and Policies | Edit |
| Account | Access: Service Tokens | Edit |
| Account | Access: Organizations, Identity Providers, and Groups | Edit |

```shell
export CLOUDFLARE_API_TOKEN=xxx
```

## Protect the origin

Access checks requests at the Cloudflare edge only. Make sure the origin accepts requests from Cloudflare only.

- ECS behind an ALB: enable `authenticated_origin_pull` in the [zone](../zone/README.md) module and use [alb-mtls](../../aws/alb-mtls/README.md).
- Static site in S3: keep the bucket private and serve it through a [Cloudflare worker](https://github.com/dbl-works/cloudflare-router). Route the hostname to the worker with `s3_cloudflare_records` in the [zone](../zone/README.md) module.

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
```

## Login method

`one_time_pin_enabled` creates the email One-time PIN identity provider.

- Cloudflare emails a six-digit code to the address the user enters
- No password and no external account
- The code is only sent when the address matches an allow policy
- Account-scoped: enable it in one module for each Cloudflare account
- Other stacks in that account set `one_time_pin_enabled = false` and pass the first stack's `one_time_pin_identity_provider_id` output
- Applications accept this provider only
- `allowed_idps` accepts any identity provider ID, and Cloudflare provider 4.52.9 does not check the type
- A nonexistent or cross-account ID fails at apply. A valid Google or Okta ID from the same account applies successfully and silently replaces the One-time PIN login
- Verify the provider type before you pass an ID
- `allow_all_identity_providers = true` overrides the restriction and accepts every identity provider on the account

## Service tokens

Send these two headers to skip the interactive login:

```shell
curl https://reports.example.com/export \
  -H "CF-Access-Client-Id: <client_id>" \
  -H "CF-Access-Client-Secret: <client_secret>"
```

Read both values from the `service_token_client_ids` and `service_token_client_secrets` outputs.

- Tokens expire one year after creation
- `service_token_min_days_for_renewal` renews a token when Terraform refreshes it inside that window. `0` disables renewal
- Renewal runs during any provider refresh, including `terraform plan`, not only during apply
- Renewal extends the expiry date. The client ID and the client secret stay the same

NOTE: Cloudflare Zero Trust is free for up to 50 users.
