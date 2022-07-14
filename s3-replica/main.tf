provider "aws" {
  alias = "replica"

  region = var.region
}

data "aws_s3_bucket" "source" {
  bucket = var.source_bucket_name
}

resource "aws_s3_bucket" "replica" {
  provider = aws.replica

  # todo: think about the replica name, should name after region
  bucket = "${var.source_bucket_name}-replica-${var.replica_region}"
}

resource "aws_s3_bucket_versioning" "replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.replica.id

  versioning_configuration {
    status = var.versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  role   = aws_iam_role.replication.arn
  bucket = data.aws_s3_bucket.source.id

  rule {
    id     = "replica-rules"
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
        replica_kms_key_id = var.kms_key_arn
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
