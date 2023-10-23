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
      "cloudtrail:DeleteTrail",
      "cloudtrail:PutEventSelectors",
      "cloudtrail:StopLogging",
      "cloudtrail:UpdateTrail",
    ]
  }
}

resource "aws_organizations_policy_attachment" "default" {
  count     = length(var.target_ids)
  policy_id = aws_organizations_policy.scp_policy.id
  # The unique identifier (ID) of the root, organizational unit, or account number that you want to attach the policy to.
  target_id = var.target_ids[count.index]
}
