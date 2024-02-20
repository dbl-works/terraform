// Allow humans to change their own passwords
resource "aws_iam_policy" "iam-humans-password" {
  name        = "IAMGuestUserChangePassword"
  path        = "/"
  description = "Allow human guests to manage their own credentials"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "iam:ChangePassword",
          "iam:GetLoginProfile"
        ],
        Resource = [
          "arn:aws:iam::*:user/guest/$${aws:username}"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "iam:GetAccountPasswordPolicy"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "humans-iam-password" {
  group      = aws_iam_group.main.name
  policy_arn = aws_iam_policy.iam-humans-password.arn
}

// Allow humans to manage their own credentials
resource "aws_iam_policy" "iam-humans-usage" {
  name        = "IAMGuestHumansUsage"
  path        = "/"
  description = "Allow human guests to manage their own credentials"

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
        Resource = "arn:aws:iam::*:user/guest/$${aws:username}"
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
        Resource = "arn:aws:iam::*:user/guest/$${aws:username}"
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
          "iam:DeleteVirtualMFADevice",
          "iam:DeactivateMFADevice"
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
        Resource = "arn:aws:iam::*:user/guest/$${aws:username}"
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "iam-humans-usage" {
  group      = aws_iam_group.main.name
  policy_arn = aws_iam_policy.iam-humans-usage.arn
}
