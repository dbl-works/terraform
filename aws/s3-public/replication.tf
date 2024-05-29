resource "aws_iam_role" "replication" {
  count = length(var.s3_replicas) > 0 ? 1 : 0
  name  = "s3CRRFor-${trim(var.bucket_name, 55)}"

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
        "s3:ReplicateTags",
        "s3:ObjectOwnerOverrideToBucketOwner"
      ],
      "Effect" : "Allow",
      "Resource" : concat([
        for replica in var.s3_replicas :
        "${replica.bucket_arn}/*"
      ], ["${module.s3.arn}/*"])
    },
    {
      "Action" : [
        "s3:ListBucket",
        "s3:GetReplicationConfiguration",
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl",
        "s3:GetObjectVersionTagging",
        "s3:GetObjectRetention",
        "s3:GetObjectLegalHold"
      ],
      "Effect" : "Allow",
      "Resource" : flatten(concat([
        module.s3.arn,
        "${module.s3.arn}/*"
        ],
        [
          for replica in var.s3_replicas :
          ["${replica.bucket_arn}/*", replica.bucket_arn]
      ]))
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
  bucket = module.s3.id

  dynamic "rule" {
    for_each = var.s3_replicas

    content {
      id       = "replica-rules-for-public-bucket-${rule.value.bucket_arn}"
      status   = "Enabled"
      priority = rule.key + 1

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
      }
    }
  }
}
