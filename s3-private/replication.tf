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
    }
  ]
  decrypt-policy = [
    {
      "Effect" : "Allow",
      "Action" : [
        "kms:Decrypt"
      ],
      "Condition" : {
        "StringLike" : {
          "kms:ViaService" : "s3.${module.s3.bucket_region}.amazonaws.com",
          "kms:EncryptionContext:aws:s3:arn" : ["${module.s3.arn}/*"]
        }
      },
      "Resource" : [
        module.s3.kms_arn
      ]
    },
  ]
  encrypt-policy = [
    for replica in var.s3_replicas : {
      "Effect" : "Allow",
      "Action" : [
        "kms:Encrypt"
      ],
      "Condition" : {
        "StringLike" : {
          "kms:ViaService" : "s3.${replica.region}.amazonaws.com",
          "kms:EncryptionContext:aws:s3:arn" : ["${replica.bucket_arn}/*"]
        }
      },
      "Resource" : [replica.kms_arn]
    }
  ]
}

resource "aws_iam_policy" "replication" {
  count = length(var.s3_replicas) > 0 ? 1 : 0
  name  = "tf-iam-role-policy-replication-for-${var.bucket_name}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : flatten(concat(
      local.replication-policy,
      local.decrypt-policy,
      local.encrypt-policy
    ))
  })
}

resource "aws_iam_role_policy_attachment" "replication" {
  count = length(var.s3_replicas) > 0 ? 1 : 0

  role       = aws_iam_role.replication[0].name
  policy_arn = aws_iam_policy.replication[0].arn
}

# Must run after aws s3 bucket versioning which is created in the s3 module
resource "aws_s3_bucket_replication_configuration" "replication" {
  count = length(var.s3_replicas) > 0 ? 1 : 0

  role   = aws_iam_role.replication[0].arn
  bucket = module.s3.id

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

      source_selection_criteria {
        # By default, Amazon S3 doesn't replicate objects that are stored at rest using server-side encryption
        # with customer managed keys stored in AWS KMS.
        # This setup will required a source kms key for the replication source bucket.

        sse_kms_encrypted_objects {
          status = "Enabled"
        }
      }
      destination {
        bucket = rule.value.bucket_arn
        # You can use multi-Region AWS KMS keys in Amazon S3.
        # However, Amazon S3 currently treats multi-Region keys as though
        # they were single-Region keys, and does not use the multi-Region features
        # of the key.
        encryption_configuration {
          # The KMS key must have been created in the same AWS Region as the destination buckets.
          replica_kms_key_id = rule.value.kms_arn
        }
      }
    }
  }
}
