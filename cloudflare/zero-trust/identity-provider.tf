# Email One-time PIN. Cloudflare sends a 6-digit code to the address the user enters.
# The code is only sent when the address matches an allow policy, so it doubles as the login filter.
resource "cloudflare_zero_trust_access_identity_provider" "otp" {
  count = var.one_time_pin_enabled ? 1 : 0

  account_id = var.account_id
  name       = "One-time PIN"
  type       = "onetimepin"
}

locals {
  # The provider is account-scoped. Either this module creates it, or another
  # stack in the same account created it and passes the ID in.
  one_time_pin_identity_provider_id = var.one_time_pin_enabled ? cloudflare_zero_trust_access_identity_provider.otp[0].id : var.one_time_pin_identity_provider_id

  # null lets Cloudflare offer every identity provider on the account. The
  # output preconditions make that reachable only through an explicit opt-in.
  allowed_idps = var.allow_all_identity_providers || local.one_time_pin_identity_provider_id == null ? null : [local.one_time_pin_identity_provider_id]
}
