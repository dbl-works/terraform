resource "aws_organizations_policy" "cloudtrail_protection_scp" {
  name        = "cloudtrail_protection_scp"
  description = "This SCP (Service Control Policy) ensures that users and roles within all impacted accounts are restricted from modifying or deleting CloudTrail logs, whether through direct command-line actions or via the AWS Management Console."
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.cloudtrail_protection_scp.json
}

data "aws_iam_policy_document" "cloudtrail_protection_scp" {
  statement {
    effect    = "Deny"
    resources = ["*"]
    actions = [
      "cloudtrail:DeleteTrail",
      "cloudtrail:PutEventSelectors",
      "cloudtrail:StopLogging",
      "cloudtrail:UpdateTrail",
    ]

    # This ensures we lock down only trails we set up using these modules
    # This allows to e.g. manually add (and then remove) trails for testing
    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/ProtectedTrail"
      values   = ["true"]
    }
  }
}

resource "aws_organizations_policy_attachment" "default" {
  count = length(var.scp_target_account_ids)

  policy_id = aws_organizations_policy.cloudtrail_protection_scp.id
  target_id = var.scp_target_account_ids[count.index]
}
