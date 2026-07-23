locals {
  name = var.name != null ? var.name : "mtls"
}

# S3 bucket — only exists because aws_lb_trust_store requires S3
module "s3_bucket" {
  source = "../s3-private"

  project     = var.project
  environment = var.environment
  bucket_name = "${var.project}-${var.environment}-${local.name}"

  # ALB Trust Store only needs to read the file, no special features required
  versioning = true

  # No user-uploaded files, only a static CA cert managed by Terraform.
  # Disable malware scanning to avoid unnecessary cost and a potential
  # race condition where the Trust Store cannot read an unscanned object.
  file_malwarescanning = {
    enabled                           = false
    allow_downloading_unscanned_files = true
  }
}

resource "aws_s3_object" "ca_bundle" {
  bucket       = module.s3_bucket.id
  key          = "ca-certificates-bundle.pem"
  content      = var.ca_certificates_pem
  content_type = "application/x-pem-file"

  # Referencing only module.s3_bucket.id would not wait for the bucket's
  # versioning configuration, and an object created before versioning is
  # enabled has no version_id for the trust store to pin.
  depends_on = [module.s3_bucket]
}

# ALB Trust Store — references the CA bundle in S3
resource "aws_lb_trust_store" "main" {
  name                                     = "${var.project}-${var.environment}-${local.name}"
  ca_certificates_bundle_s3_bucket         = module.s3_bucket.id
  ca_certificates_bundle_s3_key            = aws_s3_object.ca_bundle.key
  ca_certificates_bundle_s3_object_version = aws_s3_object.ca_bundle.version_id
  tags = {
    Name        = "${var.project}-${var.environment}-${local.name}"
    Project     = var.project
    Environment = var.environment
  }
}
