resource "aws_iam_user" "user" {
  name = "deploy-bot"
  tags = {
    name = "deploy-bot"
  }
}

output "user_name" {
  value = aws_iam_user.user.name
}

resource "aws_iam_user_group_membership" "memberships" {
  user   = "deploy-bot"
  groups = ["deploy-bot-deploy-access"]
  depends_on = [
    aws_iam_group.deploy-bot-deploy-access,
  ]
}

resource "aws_iam_policy" "deploy-bot-ecr-full-access" {
  name        = "AmazonEC2ContainerRegistryFullAccess"
  path        = "/"
  description = "Allow full access to ECR for deploy-bot"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:*",
                "cloudtrail:LookupEvents"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "deploy-bot-secrets-readonly" {
  name        = "deploy-bot-secrets-readonly"
  path        = "/"
  description = "Allow read access to secrets"

  policy = <<EOF
{
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
            "secretsmanager:DescribeSecret",
            "secretsmanager:ListSecretVersionIds",
            "secretsmanager:GetResourcePolicy",
            "secretsmanager:ListSecrets",
            "kms:ListAliases",
            "kms:DescribeKey",
            "kms:ListResourceTags",
            "kms:GetKeyRotationStatus",
            "kms:GetKeyPolicy",
            "tag:GetResources"
        ],
        "Resource" : [
            "*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
            "secretsmanager:GetSecretValue",
            "kms:Decrypt",
            "kms:GenerateDataKey"
        ],
        "Resource": [
            "arn:aws:secretsmanager:*:*:secret:*",
            "arn:aws:kms:*:*:key/*"
        ]
      }
    ]
}
EOF
}

resource "aws_iam_policy" "deploy-bot-s3-full-access" {
  name        = "S3FullAccess"
  path        = "/"
  description = "Allow full access to S3 for deploy-bot"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "S3:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_group" "deploy-bot-deploy-access" {
  name = "deploy-bot-deploy-access"
}

# Missing in "AmazonECS_FullAccess" bur required for deploying
resource "aws_iam_policy" "deploy-bot-extra-access" {
  name        = "DeployBot_ExtraAccess"
  path        = "/"
  description = "Allow extra access for deploy-bot"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecs:RegisterTaskDefinition",
          "ecs:ListServices",
          "ecs:ListTasks",
          "ecs:DescribeTaskDefinition",
          "ecs:TagResource",
          "elasticloadbalancing:Describe*",
          "iam:GetRole",
          "logs:*",
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "service-discovery-access" {
  name        = "DeployBot_ServiceDiscoveryAccess"
  path        = "/"
  description = "Service Discovery Access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "servicediscovery:TagResource",
          "servicediscovery:ListTagsForResource",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_group_policy_attachment" "deploy-bot-ecs-access" {
  group      = aws_iam_group.deploy-bot-deploy-access.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_group_policy_attachment" "deploy-bot-extra-access" {
  group      = aws_iam_group.deploy-bot-deploy-access.name
  policy_arn = aws_iam_policy.deploy-bot-extra-access.arn
}

resource "aws_iam_group_policy_attachment" "deploy-bot-ecr-access" {
  group      = aws_iam_group.deploy-bot-deploy-access.name
  policy_arn = aws_iam_policy.deploy-bot-ecr-full-access.arn
}

resource "aws_iam_group_policy_attachment" "deploy-bot-secrets-access" {
  group      = aws_iam_group.deploy-bot-deploy-access.name
  policy_arn = aws_iam_policy.deploy-bot-secrets-readonly.arn
}

resource "aws_iam_group_policy_attachment" "deploy-bot-s3-access" {
  group      = aws_iam_group.deploy-bot-deploy-access.name
  policy_arn = aws_iam_policy.deploy-bot-s3-full-access.arn
}

resource "aws_iam_group_policy_attachment" "service-discovery-access" {
  group      = aws_iam_group.deploy-bot-deploy-access.name
  policy_arn = aws_iam_policy.service-discovery-access.arn
}
