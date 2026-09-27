locals {
  service_token_applications = {
    for key, app in var.applications : key => app if app.service_token_enabled
  }
}

# Machine access: the client sends CF-Access-Client-Id / CF-Access-Client-Secret headers instead of logging in.
resource "cloudflare_zero_trust_access_service_token" "main" {
  for_each = local.service_token_applications

  account_id           = var.account_id
  name                 = "${var.project}-${var.environment}-${each.key}"
  min_days_for_renewal = var.service_token_min_days_for_renewal
}

resource "cloudflare_zero_trust_access_policy" "allow_service_token" {
  for_each = local.service_token_applications

  account_id     = var.account_id
  application_id = cloudflare_zero_trust_access_application.main[each.key].id
  name           = "allow-service-token"
  precedence     = 2
  decision       = "non_identity"

  include {
    service_token = [cloudflare_zero_trust_access_service_token.main[each.key].id]
  }
}
