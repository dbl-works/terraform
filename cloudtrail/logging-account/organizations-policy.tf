data "aws_caller_identity" "current" {}

resource "aws_organizations_policy" "scp_policy" {
  name        = "scp_cloudtrail"
  description = "This SCP prevents users or roles in any affected account from disabling a CloudTrail log, either directly as a command or through the console. "
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.scp_policy.json
}

data "aws_iam_policy_document" "scp_policy" {
  statement {
    effect    = "Deny"
    resources = ["*"]
    actions = [
      "cloudtrail:StopLogging",
      "cloudtrail:DeleteTrail"
    ]
  }
}

resource "aws_organizations_policy_attachment" "default" {
  policy_id = aws_organizations_policy.scp_policy.id
  target_id = data.aws_caller_identity.current.account_id
}
