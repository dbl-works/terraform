resource "aws_iam_user" "guest" {
  name = "guest-${var.guest_account_name}"
  path = "/guest/"

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

data "aws_iam_policy_document" "s3" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging",
      "s3:DeleteObject"
    ]
    resources = [
      module.s3.arn,
      "${module.s3.arn}/*",
    ]
  }
}

resource "aws_iam_user_policy" "s3" {
  name   = "s3-access-for-${module.s3.bucket_name}"
  user   = aws_iam_user.guest.name
  policy = data.aws_iam_policy_document.s3.json
}

resource "aws_iam_policy" "iam-humans-usage" {
  name        = "IAMHumansUsage"
  path        = "/"
  description = "Allow humans to manage their own credentials"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowViewAccountInfo",
        Effect = "Allow",
        Action = [
          "iam:GetAccountPasswordPolicy",
          "iam:GetAccountSummary",
          "iam:ListVirtualMFADevices"
        ],
        Resource = "*"
      },
      {
        Sid    = "AllowManageOwnPasswords",
        Effect = "Allow",
        Action = [
          "iam:ChangePassword",
          "iam:GetUser"
        ],
        Resource = "arn:aws:iam::*:user/$${aws:username}"
      },
      {
        Sid    = "AllowManageOwnAccessKeys",
        Effect = "Allow",
        Action = [
          "iam:CreateAccessKey",
          "iam:DeleteAccessKey",
          "iam:GetAccessKeyLastUsed",
          "iam:ListAccessKeys",
          "iam:UpdateAccessKey"
        ],
        Resource = "arn:aws:iam::*:user/$${aws:username}"
      },
      {
        Sid    = "AllowCreateVirtualMFADevice",
        Effect = "Allow",
        Action = [
          "iam:CreateVirtualMFADevice",
        ],
        "Resource" : "arn:aws:iam::*:mfa/*"
      },
      {
        Sid    = "AllowDeleteVirtualMFADevice",
        Effect = "Allow",
        Action = [
          "iam:DeleteVirtualMFADevice"
        ],
        Resource = "arn:aws:iam::*:mfa/*",
        Condition = {
          "Bool" : {
            "aws:MultiFactorAuthPresent" : "true"
          }
        }
      },
      {
        Sid    = "AllowManageOwnUserMFA",
        Effect = "Allow",
        Action = [
          "iam:DeactivateMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ResyncMFADevice"
        ],
        Resource = "arn:aws:iam::*:user/$${aws:username}"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "iam-humans-usage" {
  user       = aws_iam_user.guest.name
  policy_arn = aws_iam_policy.iam-humans-usage.arn
}
