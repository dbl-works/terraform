variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "ca_certificates_pem" {
  description = "PEM-encoded root CA certificate that signed the Cloudflare client certificate."
  type        = string
  sensitive   = true
}

variable "name" {
  description = "Name prefix for trust store resources. Defaults to mTLS."
  type        = string
  default     = "mtls"
}
