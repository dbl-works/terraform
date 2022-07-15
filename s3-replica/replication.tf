resource "aws_s3_bucket_replication_configuration" "replication_for_private_bucket" {
  count  = var.enable_encryption ? 1 : 0
  provider = "aws.source"

  role   = aws_iam_role.replication.arn
  bucket = var.source_bucket_arn

  rule {
    id     = "replica-rules-for-private-bucket"
    status = "Enabled"

    source_selection_criteria {
      # By default, Amazon S3 doesn't replicate objects that are stored at rest using server-side encryption
      # with customer managed keys stored in AWS KMS.
      # This setup will required a source kms key for the replication source bucket.

      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }
    destination {
      bucket = aws_s3_bucket.replica.arn
      # You can use multi-Region AWS KMS keys in Amazon S3.
      # However, Amazon S3 currently treats multi-Region keys as though
      # they were single-Region keys, and does not use the multi-Region features
      # of the key.
      encryption_configuration {
        # The KMS key must have been created in the same AWS Region as the destination buckets.
        replica_kms_key_id = module.kms_key.arn
      }

      # S3 Replication Time Control (S3 RTC) helps you meet compliance or business requirements for data replication and
      # provides visibility into Amazon S3 replication times.
      # S3 RTC replicates most objects that you upload to Amazon S3 in seconds,
      # and 99.99 percent of those objects within 15 minutes.
      replication_time = {
        status  = "Enabled"
        minutes = 15
      }
    }
  }
}

# Does this need to be in the specified region
resource "aws_s3_bucket_replication_configuration" "replication_for_public_bucket" {
  count    = var.enable_encryption ? 0 : 1
  provider = "aws.source"

  role   = aws_iam_role.replication.arn
  bucket = var.source_bucket_arn

  rule {
    id     = "replica-rules-for-public-bucket"
    status = "Enabled"

    destination {
      bucket = aws_s3_bucket.replica.arn
      # S3 Replication Time Control (S3 RTC) helps you meet compliance or business requirements for data replication and
      # provides visibility into Amazon S3 replication times.
      # S3 RTC replicates most objects that you upload to Amazon S3 in seconds,
      # and 99.99 percent of those objects within 15 minutes.
      replication_time = {
        status  = "Enabled"
        minutes = 15
      }
    }
  }
}
