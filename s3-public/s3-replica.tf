resource "aws_iam_role" "replication" {
  count = length(var.s3_replicas) > 0 ? 1 : 0
  name  = "s3-replication-role-for-${var.bucket_name}-replica"

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

locals {
  replication-policy = [
    {
      "Action" : [
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags"
      ],
      "Effect" : "Allow",
      "Resource" : [for replica in var.s3_replicas : "${replica.bucket_arn}/*"]
    },
    {
      "Action" : [
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl",
        "s3:GetObjectVersionTagging"
      ],
      "Effect" : "Allow",
      "Resource" : [
        "${aws_s3_bucket.main.arn}/*"
      ]
    },
    {
      "Action" : [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect" : "Allow",
      "Resource" : [
        "${aws_s3_bucket.main.arn}"
      ]
    },
  ]
}

resource "aws_iam_policy" "replication" {
  count = length(var.s3_replicas) > 0 ? 1 : 0
  name  = "tf-iam-role-policy-replication-for-${var.bucket_name}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : local.replication-policy
  })
}

resource "aws_iam_role_policy_attachment" "replication" {
  count = length(var.s3_replicas) > 0 ? 1 : 0

  role       = aws_iam_role.replication[0].name
  policy_arn = aws_iam_policy.replication[0].arn
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  count = length(var.s3_replicas) > 0 ? 1 : 0

  role   = aws_iam_role.replication[0].arn
  bucket = aws_s3_bucket.main.id

  dynamic "rule" {
    for_each = var.s3_replicas

    content {
      id     = "replica-rules-for-private-bucket-${rule.key}"
      status = "Enabled"

      filter {}

      # Enabled: The delete marker is replicated
      # A subsequent GET request to the deleted object in both the source and the destination bucket
      # does not return the object.
      # Disabled: The delete marker is not replicated
      # A subsequent GET request to the deleted object returns the object only in the destination bucket.
      delete_marker_replication {
        status = "Enabled"
      }

      destination {
        bucket = rule.value.bucket_arn
        metrics {
          event_threshold {
            minutes = 15
          }
          status = "Enabled"
        }

        # S3 Replication Time Control (S3 RTC) helps you meet compliance or business requirements for data replication and
        # provides visibility into Amazon S3 replication times.
        # S3 RTC replicates most objects that you upload to Amazon S3 in seconds,
        # and 99.99 percent of those objects within 15 minutes.
        replication_time {
          status = "Enabled"
          time {
            minutes = 15
          }
        }
      }
    }
  }
}
