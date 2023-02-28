# You would need to have docker install to run this file properly
resource "aws_lambda_layer_version" "package_layer" {
  count               = var.lambda_layer_source == null ? 0 : 1
  layer_name          = "packages-layers"
  compatible_runtimes = [var.runtime]

  s3_bucket = var.lambda_layer_source.lambda_layer_s3_bucket
  s3_key    = var.lambda_layer_source.lambda_layer_s3_key
}
