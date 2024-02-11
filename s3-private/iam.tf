locals {
  name = var.bucket_name != null ? var.bucket_name : "${var.project}-${var.environment}${var.regional ? "-${var.region}" : ""}"
  s3-policy = var.policy_allow_listing_all_buckets ? [
    {
      "Effect" : "Allow",
      "Action" : [
        "s3:ListAllMyBuckets",
        "s3:GetBucketLocation",
      ],
      "Resource" : [
        "arn:aws:s3:::*",
      ]
    }
    ] : [
    {
      "Effect" : "Allow",
      "Action" : [
        "s3:ListBucket",
        "s3:ListBucketVersions",
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
      "Resource" : [
        "arn:aws:s3:::${var.bucket_name}",
        "arn:aws:s3:::${var.bucket_name}/*"
      ]
    },
  ]
  kms-policy = module.s3.kms_arn == null ? [] : [
    {
      "Effect" : "Allow",
      "Action" : [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Resource" : [
        "${module.s3.kms_arn}"
      ]
    },
  ]
}

resource "aws_iam_group" "usage" {
  name = "${local.name}-s3-usage"
}

resource "aws_iam_policy" "usage" {
  name        = "${local.name}-s3-usage"
  description = "For uploading/downloading encrypted files on S3"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : concat(
      local.s3-policy,
      local.kms-policy
    )
  })
}

resource "aws_iam_group_policy_attachment" "usage" {
  group      = aws_iam_group.usage.name
  policy_arn = aws_iam_policy.usage.arn
}
