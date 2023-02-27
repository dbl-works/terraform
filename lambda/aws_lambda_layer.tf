# You would need to have docker install to run this file properly
resource "aws_lambda_layer_version" "package_layer" {
  count               = var.package_layer_source_zip_file_path == null ? 0 : 1
  filename            = var.package_layer_source_zip_file_path
  layer_name          = "packages-layers"
  source_code_hash    = filebase64sha256(var.package_layer_source_zip_file_path)
  compatible_runtimes = [var.runtime]
}
