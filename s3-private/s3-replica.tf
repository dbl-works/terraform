resource "aws_iam_role" "replication" {
  count = length(var.s3_replicas) > 0 ? 1: 0
  name = "s3-replication-role-for-${var.bucket_name}-replica"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "replication" {
  count = length(var.s3_replicas) > 0 ? 1: 0
  name = "tf-iam-role-policy-replication"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.main.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl",
        "s3:GetObjectVersionTagging"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.main.arn}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags"
      ],
      "Effect": "Allow",
      "Resource": "${[for replica in var.s3_replicas : "${replica.bucket_arn}/*"]}"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "replication" {
  count = length(var.s3_replicas) > 0 ? 1: 0

  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}

# Does this need to be in the specified region
resource "aws_s3_bucket_replication_configuration" "replication_for_public_bucket" {
  count = length(var.s3_replicas) > 0 ? 1: 0

  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.main.arn

  dynamic "replica" {
    for_each = var.s3_replicas

    rule {
      id     = "replica-rules-for-private-bucket-${replica.key}"
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
        bucket = replica.value.bucket_arn
        # You can use multi-Region AWS KMS keys in Amazon S3.
        # However, Amazon S3 currently treats multi-Region keys as though
        # they were single-Region keys, and does not use the multi-Region features
        # of the key.
        encryption_configuration {
          # The KMS key must have been created in the same AWS Region as the destination buckets.
          replica_kms_key_id = replica.value.kms_arn
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
}
