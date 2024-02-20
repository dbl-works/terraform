locals {
  resources = [
    "acm",
    "application-autoscaling",
    "cloudwatch",
    "cognito-identity",
    "cognito-idp",
    "ecr",
    "ecs",
    "ec2",
    "elasticloadbalancing",
    "elasticache",
    "rds",
    "s3"
  ]

  admin_resources = [
    "kms",
    "secretsmanager",
  ]
}

