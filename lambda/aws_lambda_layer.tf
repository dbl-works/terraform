locals {
  # Where we store the zip file
  package_layer_source_zip_file = "lambda_layer/packages/lambda_layers.zip"
}

resource "null_resource" "build_layer" {
  provisioner "local-exec" {
    command = "/bin/bash lambda_layer/build.sh"
    environment = {
      PYTHON_VERSION = "3.9"
    }
  }
}

# You would need to have docker install to run this file properly
resource "aws_lambda_layer_version" "package_layer" {
  filename            = local.package_layer_source_zip_file
  layer_name          = "packages-layers"
  source_code_hash    = filebase64sha256(local.package_layer_source_zip_file)
  compatible_runtimes = ["python3.9", "python3.8"]

  depends_on = [
    null_resource.build_layer
  ]
}
