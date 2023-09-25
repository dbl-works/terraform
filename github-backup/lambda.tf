module "lambda" {
  source = "../lambda"

  # Required
  environment   = var.environment
  project       = var.github_org
  source_dir    = "./src"
  function_name = "${var.github_org}-${var.environment}-github-backup"
  runtime       = var.ruby_major_version == "3" ? "ruby3.2" : "ruby2.7"
  timeout       = var.timeout
  memory_size   = var.memory_size

  # Optional
  handler = "main.call"

  secrets_and_kms_arns = [
    module.secrets.arn,
    module.secrets.kms_key_arn,
  ]

  environment_variables = {
    S3_BUCKET  = module.s3-main.bucket_name,
    SECRET_ID  = module.secrets.id,
    GITHUB_ORG = var.github_org,
  }
}
