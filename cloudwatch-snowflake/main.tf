module "fivetran_lambda" {
  source = "../fivetran/connectors/lambda"

  fivetran_api_key       = var.fivetran_api_key
  fivetran_api_secret    = var.fivetran_api_secret
  fivetran_group_id      = var.fivetran_group_id
  organisation           = var.organisation
  tracked_resources_data = []

  # optional
  aws_region_code         = var.aws_region_code
  fivetran_aws_account_id = var.fivetran_aws_account_id
  lambda_role_arn         = var.lambda_role_arn
  # Check on this whether it is refer to here or the fivetran_lambda module
  lambda_source_dir  = "${path.module}/tracker"
  lambda_output_path = "${path.module}/dist/tracker.zip"
  script_env = {
    RESOURCES_DATA = jsonencode(var.tracked_resources_data)
    PERIOD         = "3600"
  }

  # for the backward compatibility of the previous version
  connector_name = var.organisation == null ? null : "cloudwatch_metrics_${var.organisation}_${replace(var.aws_region_code, "/-/", "_")}"
}

resource "aws_iam_role_policy_attachment" "fivetran_policy_for_lambda" {
  count      = var.lambda_role_arn == null ? 1 : 0
  role       = aws_iam_role.lambda[0].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}
