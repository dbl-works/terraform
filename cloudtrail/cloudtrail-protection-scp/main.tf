resource "aws_organizations_policy" "cloudtrail_protection_scp" {
  name        = "scp_cloudtrail"
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

    # this ensures we only protect logs that are ingested by the log ingester account
    # which allows to have additional trails within a single log-producer account that are not protected
    condition {
      test     = "StringLike"
      variable = "cloudtrail:trailarn"
      values   = ["arn:aws:cloudtrail:*:${var.log_ingester_account_id}:trail/*"]
    }
  }
}

resource "aws_organizations_policy_attachment" "default" {
  count     = length(var.scp_target_account_ids)
  policy_id = aws_organizations_policy.cloudtrail_protection_scp.id
  # The unique identifier (ID) of the root, organizational unit, or account number that you want to attach the policy to.
  target_id = var.scp_target_account_ids[count.index]
}
