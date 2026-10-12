resource "cloudflare_zero_trust_access_application" "main" {
  for_each = var.applications

  account_id       = var.account_id
  name             = "${var.project}-${var.environment}-${each.key}"
  domain           = each.value.hostname
  type             = "self_hosted"
  session_duration = each.value.session_duration
  logo_url         = each.value.logo_url

  # Without allowed_idps Cloudflare offers every identity provider on the account.
  allowed_idps = local.allowed_idps

  # Show the Cloudflare login page instead of jumping straight to a single provider.
  auto_redirect_to_identity = false
  app_launcher_visible      = true
}

# Interactive users: allow by email address and/or email domain.
resource "cloudflare_zero_trust_access_policy" "allow_users" {
  for_each = var.applications

  account_id     = var.account_id
  application_id = cloudflare_zero_trust_access_application.main[each.key].id
  name           = "allow-users"
  precedence     = 1
  decision       = "allow"

  include {
    email        = each.value.allowed_emails
    email_domain = each.value.allowed_email_domains
  }
}
