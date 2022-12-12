locals {
  name = var.name != null ? var.name : "${var.project}-${var.environment}${var.regional ? "-${var.region}" : ""}"
}

resource "aws_iam_group" "usage" {
  name = "${local.name}-s3-usage"
}

resource "aws_iam_policy" "usage" {
  name        = "${local.name}-s3-usage"
  description = "For uploading/downloading encrypted files on S3"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    ${var.policy_allow_listing_all_buckets ? "{\"Effect\": \"Allow\", \"Action\": [\"s3:ListAllMyBuckets\", \"s3:ListBucketVersions\", \"s3:GetBucketLocation\"], \"Resource\": \"arn:aws:s3:::*\"}," : ""}
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:ListObjectVersions",
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:PutObjectVersion",
        "s3:PutObjectVersionAcl",
        "s3:DeleteObject",
        "s3:DeleteObjectVersion"
      ],
      "Resource": [
        "arn:aws:s3:::${var.bucket_name}",
        "arn:aws:s3:::${var.bucket_name}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Resource": [
        "${module.s3.kms_arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_group_policy_attachment" "usage" {
  group      = aws_iam_group.usage.name
  policy_arn = aws_iam_policy.usage.arn
}
