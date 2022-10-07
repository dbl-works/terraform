module "lambda_role" {
  source = "github.com/dbl-works/terraform//iam/iam-policy-for-fivetran-lambda?ref=v2022.07.05"

  fivetran_group_id       = "fivetran-group-id" # Also know as external_id. Understand the group concept here: https://fivetran.com/docs/getting-started/powered-by-fivetran#createagroupusingtheui
  fivetran_aws_account_id = "834469178297"      # Fivetran AWS account ID. We need to allow this account to access our lambda function.
}

resource "aws_iam_role_policy_attachment" "fivetran_policy_for_lambda" {
  role       = module.lambda_role.lambda_role_name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}
