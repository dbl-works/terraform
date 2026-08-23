variable "domain_name" {
  description = "Domain registered with Route 53 Domains."
  type        = string

  validation {
    condition     = length(trimspace(var.domain_name)) > 0
    error_message = "domain_name must not be empty."
  }
}

variable "dnssec_algorithm" {
  description = "DNSSEC algorithm reported by the authoritative DNS provider."
  type        = number

  validation {
    condition     = var.dnssec_algorithm > 0 && floor(var.dnssec_algorithm) == var.dnssec_algorithm
    error_message = "dnssec_algorithm must be a positive integer."
  }
}

variable "dnssec_flags" {
  description = "DNSKEY flags reported by the authoritative DNS provider: 257 for KSK or 256 for ZSK."
  type        = number

  validation {
    condition     = contains([256, 257], var.dnssec_flags)
    error_message = "dnssec_flags must be 257 (KSK) or 256 (ZSK)."
  }
}

variable "dnssec_public_key" {
  description = "Base64-encoded DNSSEC public key reported by the authoritative DNS provider."
  type        = string

  validation {
    condition     = length(trimspace(var.dnssec_public_key)) > 0
    error_message = "dnssec_public_key must not be empty."
  }
}
