locals {
  function_name      = replace(join("_", compact([var.service_name, var.project, var.environment, var.aws_region_code])), "/-/", "_")
  is_role_name_exist = var.lambda_role_name != null || length(aws_iam_role.lambda) > 0
  lambda_role_arn    = var.lambda_role_arn != null ? var.lambda_role_arn : (var.lambda_role_name != null ? data.aws_iam_role.lambda[0].arn : aws_iam_role.lambda[0].name)
}
