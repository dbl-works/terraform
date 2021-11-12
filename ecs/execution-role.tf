resource "aws_iam_role" "ecs-task-execution" {
  name = "ecs-task-execution-${var.project}-${var.environment}"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ]

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

locals {
  ecs-task-execution-policy-default = [
    {
      "Effect" : "Allow",
      "Action" : [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource" : "*"
    },
    {
      "Effect" : "Allow",
      "Action" : [
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ],
      "Resource" : "*"
    },
    {
      "Effect" : "Allow",
      "Action" : [
        "ecs:DescribeServices",
        "ecs:DescribeTasks",
        "ecs:ListTasks"
      ],
      "Resource" : "*"
    }
  ]

  ecs-task-execution-policy-s3-read = length(var.grant_read_access_to_s3_arns) > 0 ? [{
    "Effect" : "Allow",
    "Action" : [
      "s3:ListBucket",
      "s3:GetObject"
    ],
    "Resource" : var.grant_read_access_to_s3_arns
  }] : []

  ecs-task-execution-policy-s3-write = length(var.grant_write_access_to_s3_arns) > 0 ? [{
    "Effect" : "Allow",
    "Action" : [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ],
    "Resource" : var.grant_write_access_to_s3_arns
  }] : []
}

resource "aws_iam_role_policy" "ecs-task-execution-policy" {
  name = "ecs-task-execution-policy"
  role = aws_iam_role.ecs-task-execution.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : concat(
      local.ecs-task-execution-policy-default,
      local.ecs-task-execution-policy-s3-read,
      local.ecs-task-execution-policy-s3-write
    )
  })
}

resource "aws_iam_role_policy" "ecs-task-execution-secrets-policy" {
  name = "ecs-task-execution-secrets-policy"
  role = aws_iam_role.ecs-task-execution.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"
        ],
        "Resource" : flatten([
          var.secrets_arns,
          var.kms_key_arns,
        ]),
      }
    ]
  })
}
