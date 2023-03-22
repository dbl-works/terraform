module "lambda" {
  source = "../lambda"

  function_name = "ecr-scanner-notifier"
  project       = "reveneo"
  environment   = "production"
  source_dir    = "./script"

  # optional
  handler = "lambda.lambda_handler"

  # Subnets the lambdas are allowed to use to access resources in the VPC.
  subnet_ids = []

  # You can get the list of available lambda layers here
  # https://github.com/keithrozario/Klayers
  aws_lambda_layer_arns = []

  # To allow or deny specific access to resources in the VPC.
  security_group_ids = []

  # [optional] Grant access to the lambda function to Secrets and KMS keys
  secrets_and_kms_arns = []
}
