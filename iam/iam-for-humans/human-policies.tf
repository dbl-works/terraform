// Allow humans to change their own passwords
resource "aws_iam_group_policy_attachment" "humans-iam-password" {
  group      = "humans"
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}

// Allow humans to manage their own credentials
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
      },
      {
        Sid    = "DenyAllExceptListedIfNoMFA",
        Effect = "Deny",
        NotAction = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ListVirtualMFADevices",
          "iam:ResyncMFADevice",
          "sts:GetSessionToken"
        ],
        Resource = "*",
        Condition = {
          "BoolIfExists" : { "aws:MultiFactorAuthPresent" : "false" }
        }
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "iam-humans-usage" {
  group      = "humans"
  policy_arn = aws_iam_policy.iam-humans-usage.arn
}
