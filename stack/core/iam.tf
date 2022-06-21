## IAM
module "iam_policies" {
  source      = "../../iam-policy-for-taggable-resources"
  environment = var.environment
}

resource "aws_iam_group_policy_attachment" "engineer" {
  group      = "engineer" # from global infrastructure: `aws_iam_group.engineer.name`
  policy_arn = module.iam_policies.policy_arn
}
