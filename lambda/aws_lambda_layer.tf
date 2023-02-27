# You would need to have docker install to run this file properly
resource "aws_lambda_layer_version" "package_layer" {
  count               = var.lambda_layer_source_zip_file == null ? 0 : 1
  filename            = var.lambda_layer_source_zip_file
  layer_name          = "packages-layers"
  source_code_hash    = filebase64sha256(var.lambda_layer_source_zip_file)
  compatible_runtimes = [var.runtime]
}
