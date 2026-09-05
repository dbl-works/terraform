output "application_ids" {
  description = "Access application ID per key."
  value       = { for key, app in cloudflare_zero_trust_access_application.main : key => app.id }
}

output "application_auds" {
  description = "Application Audience (AUD) tag per key. Use it to verify the Cf-Access-Jwt-Assertion header at the origin."
  value       = { for key, app in cloudflare_zero_trust_access_application.main : key => app.aud }
}

output "service_token_client_ids" {
  description = "CF-Access-Client-Id per key, for applications with service_token_enabled."
  value       = { for key, token in cloudflare_zero_trust_access_service_token.main : key => token.client_id }
}

output "service_token_client_secrets" {
  description = "CF-Access-Client-Secret per key, for applications with service_token_enabled."
  value       = { for key, token in cloudflare_zero_trust_access_service_token.main : key => token.client_secret }
  sensitive   = true
}
