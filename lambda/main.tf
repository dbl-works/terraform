data "archive_file" "zip" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${path.module}/dist/${var.function_name}.zip"
}


resource "aws_lambda_function" "main" {
  function_name = var.function_name
  role          = aws_iam_role.main.arn

  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256 # Used to trigger updates
  handler          = var.handler
  runtime          = var.runtime
  timeout          = var.timeout
  memory_size      = var.memory_size
  layers           = var.aws_lambda_layer_arns

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
