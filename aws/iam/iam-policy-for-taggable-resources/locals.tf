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
    "s3",
    "waf",
    "wafv2",
    "waf-regional"
  ]

  admin_resources = [
    "kms",
    "secretsmanager",
  ]
}

