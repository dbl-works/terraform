resource "aws_organizations_policy" "scp_policy" {
  count = var.is_organization_trail ? 1 : 0

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
  count = var.is_organization_trail ? 1 : 0

  policy_id = aws_organizations_policy.scp_policy[0].id
  # The unique identifier (ID) of the root, organizational unit, or account number that you want to attach the policy to.
  target_id = data.aws_caller_identity.current.account_id
}
