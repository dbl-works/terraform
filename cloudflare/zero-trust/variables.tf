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
}

variable "one_time_pin_identity_provider_id" {
  description = "ID of an existing One-time PIN identity provider. Set it together with one_time_pin_enabled = false to reuse the provider another stack created in this account."
  type        = string
  default     = null
}

variable "service_token_min_days_for_renewal" {
  description = "Regenerate a service token when an apply runs within this many days of its expiry. 0 disables renewal. Renewal issues a new client secret, so every caller must read the new value."
  type        = number
  default     = 0
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
