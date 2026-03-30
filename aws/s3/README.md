# Terraform Module: S3

A repository for setting up an S3 bucket

## Usage
### How to create S3 replica for private and public bucket
```terraform
module "s3" {
  source = "../s3"

  environment = "staging"
  project     = "someproject"
  bucket_name = "someproject-staging-frontend"

  # Optional
  versioning                  = var.versioning
  kms_deletion_window_in_days = 30
  enable_encryption           = true
  multi_region_kms_key        = false  # If true, the KMS key can be used in other regions
}
```

## Malware Scanning

This module supports automatic malware scanning of uploaded objects using [AWS GuardDuty Malware Protection for S3](https://docs.aws.amazon.com/guardduty/latest/ug/malware-protection-s3.html). This feature works independently — it does **not** require enabling the full GuardDuty service.

When enabled, every newly uploaded object is automatically scanned and tagged with a `GuardDutyMalwareScanStatus` tag (`NO_THREATS_FOUND`, `THREATS_FOUND`, `UNSUPPORTED`, etc.).

### Configuration

| Variable | Type | Default | Description |
|---|---|---|---|
| `file_malwarescanning_enabled` | `bool` | `false` | Enable GuardDuty Malware Protection for S3 on this bucket. |
| `allow_downloading_unscanned_files` | `bool` | `true` | If `true`, only blocks downloads of files tagged as `THREATS_FOUND`. If `false`, blocks any file not explicitly tagged as `NO_THREATS_FOUND`. |

```terraform
module "s3" {
  source = "../s3"

  environment = "staging"
  project     = "someproject"
  bucket_name = "someproject-staging-uploads"

  file_malwarescanning_enabled      = true
  allow_downloading_unscanned_files = true  # Set to false after backfilling scans
}
```

### Enabling on an Existing Bucket

When enabling malware scanning on a bucket that already contains files, follow these steps:

1. **Deploy with scanning enabled** and `allow_downloading_unscanned_files = true` (the default). This ensures new uploads are scanned while existing files remain downloadable.

2. **Backfill scans for historical files** using the provided utility script:
   ```sh
   export AWS_PROFILE=your-profile

   # Scan the entire bucket (skips already-tagged objects, safe to stop and re-run)
   ./script/backfill_s3_malware_scan.sh <bucket-name>

   # Scan a specific prefix
   ./script/backfill_s3_malware_scan.sh <bucket-name> --prefix uploads/ --region eu-central-1
   ```

3. **Once all objects are tagged**, change `allow_downloading_unscanned_files = false` and apply. Only confirmed clean files will be downloadable from this point on.

### Pricing

GuardDuty Malware Protection for S3 costs approximately **~$0.10 per GiB scanned**.

- [GuardDuty Malware Protection for S3 — Pricing](https://docs.aws.amazon.com/guardduty/latest/ug/pricing-malware-protection-for-s3-guardduty.html)
- [Amazon GuardDuty Malware Protection for S3 — Price Reduction Announcement](https://aws.amazon.com/about-aws/whats-new/2025/02/amazon-guardduty-malware-protection-s3-price-reduction/)
