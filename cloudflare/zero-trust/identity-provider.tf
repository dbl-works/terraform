# Email One-time PIN. Cloudflare sends a 6-digit code to the address the user enters.
# The code is only sent when the address matches an allow policy, so it doubles as the login filter.
resource "cloudflare_zero_trust_access_identity_provider" "otp" {
  count = var.one_time_pin_enabled ? 1 : 0

  account_id = var.account_id
  name       = "One-time PIN"
  type       = "onetimepin"
}
