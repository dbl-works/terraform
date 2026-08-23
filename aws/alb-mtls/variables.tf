variable "project" {
  type = string
}

variable "environment" {
  type = string
}

# Not marked sensitive: a CA certificate is public material, and sensitivity
# would propagate into plan output, hiding the trust store and listener diffs.
variable "ca_certificates_pem" {
  description = "PEM-encoded root CA certificate that signed the Cloudflare client certificate."
  type        = string
}

variable "name" {
  description = "Name prefix for trust store resources. Defaults to mTLS."
  type        = string
  default     = "mtls"
}
