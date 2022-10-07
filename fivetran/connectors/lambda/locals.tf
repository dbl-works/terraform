locals {
  function_name      = replace(join("_", compact([var.service_name, var.project, var.environment, var.aws_region_code])), "/-/", "_")
  is_role_name_exist = var.lambda_role_name != null || length(aws_iam_role.lambda) > 0
}
