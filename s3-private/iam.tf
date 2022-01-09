resource "aws_iam_group" "usage" {
  name = "${var.project}-${var.environment}-s3-usage"
}

resource "aws_iam_policy" "usage" {
  name        = "${var.project}-${var.environment}-s3-usage"
  description = "For uploading/downloading encrypted storage files on S3"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListAllMyBuckets",
        "s3:GetBucketLocation"
      ],
      "Resource": "arn:aws:s3:::*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": [
        "arn:aws:s3:::${var.project}-${var.environment}-storage",
        "arn:aws:s3:::${var.project}-${var.environment}-storage/*"
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
        "${module.kms-key-s3.arn}"
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
