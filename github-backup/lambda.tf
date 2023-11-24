module "lambda" {
  source = "../lambda"

  # Required
  environment   = var.environment
  project       = var.github_org
  source_dir    = "${path.module}/src"
  function_name = "${var.github_org}-${var.environment}-github-backup"
  runtime       = var.ruby_major_version == "3" ? "ruby3.2" : "ruby2.7"
  timeout       = var.timeout
  memory_size   = var.memory_size

  # Optional
  handler = "main.call"

  secrets_and_kms_arns = [
    module.secrets.arn,
    module.secrets.kms_key_arn
  ]

  environment_variables = {
    S3_BUCKET  = module.s3-main.bucket_name,
    SECRET_ID  = module.secrets.id,
    GITHUB_ORG = var.github_org,
  }

  lambda_policy_json = data.aws_iam_policy_document.s3.json
}

data "aws_iam_policy_document" "s3" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${module.s3-main.arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey"
    ]
    resources = [
      module.s3-main.kms-key-arn
    ]
  }
}
