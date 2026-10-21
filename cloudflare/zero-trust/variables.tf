variable "account_id" {
  description = "Cloudflare account ID. Access applications are account-scoped."
  type        = string
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "one_time_pin_enabled" {
  description = "Create the email One-time PIN identity provider. The provider is account-scoped, so set this to false when another stack already manages it for this Cloudflare account."
  type        = bool
  default     = true
  nullable    = false
}

variable "one_time_pin_identity_provider_id" {
  description = "ID of an existing One-time PIN identity provider. Set it together with one_time_pin_enabled = false to reuse the provider another stack created in this account. Cloudflare provider 4.52.9 does not check the provider type behind the ID: a nonexistent or cross-account ID fails at apply, but a valid Google or Okta ID from the same account applies successfully and replaces the One-time PIN login. Verify the provider type before you pass an ID."
  type        = string
  default     = null

  validation {
    condition     = var.one_time_pin_identity_provider_id == null || can(regex("\\S", var.one_time_pin_identity_provider_id))
    error_message = "one_time_pin_identity_provider_id must be null or contain a non-whitespace ID."
  }
}

variable "allow_all_identity_providers" {
  description = "Accept every identity provider on the account instead of restricting the applications to the One-time PIN provider. This overrides the One-time PIN restriction even when this module creates or reuses that provider. Required to run without a known provider ID."
  type        = bool
  default     = false
  nullable    = false
}

variable "service_token_min_days_for_renewal" {
  description = "Renew a service token when Terraform refreshes it within this many days of its expiry. 0 disables renewal. Renewal extends the expiry date and keeps the client ID and client secret."
  type        = number
  default     = 0
  nullable    = false

  validation {
    condition     = var.service_token_min_days_for_renewal >= 0 && floor(var.service_token_min_days_for_renewal) == var.service_token_min_days_for_renewal
    error_message = "service_token_min_days_for_renewal must be a whole number of days, 0 or greater."
  }
}

variable "applications" {
  description = <<-EOT
    Map of Access applications keyed by a short name, e.g. "admin".
    Each application protects one hostname. Requests to that hostname must pass one of the allow rules.
    At least one of allowed_emails or allowed_email_domains must be set.
  EOT
  type = map(object({
    hostname              = string                     # e.g. "admin.example.com" or "admin.example.com/internal"
    session_duration      = optional(string, "24h")    # 30m, 6h, 12h, 24h, 168h, 730h
    allowed_emails        = optional(list(string), []) # exact addresses
    allowed_email_domains = optional(list(string), []) # e.g. ["example.com"]
    service_token_enabled = optional(bool, false)      # create a client id/secret pair for non-interactive access (CI, scripts)
    logo_url              = optional(string, null)
  }))

  validation {
    condition = alltrue([
      for app in var.applications : length(app.allowed_emails) + length(app.allowed_email_domains) > 0
    ])
    error_message = "Each application needs at least one entry in allowed_emails or allowed_email_domains."
  }
}
