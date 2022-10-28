resource "aws_iam_role" "ecs-task-execution" {
  name = "ecs-task-execution-${local.name}"
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
      "s3:GetObject",
      "s3:GetObjectVersion"
    ],
    "Resource" : sort(flatten([
      var.grant_read_access_to_s3_arns,
      [for arn in var.grant_read_access_to_s3_arns : "${arn}/*"],
    ]))
  }] : []

  ecs-task-execution-policy-s3-write = length(var.grant_write_access_to_s3_arns) > 0 ? [{
    "Effect" : "Allow",
    "Action" : [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectVersion",
      "s3:PutObjectVersionAcl",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion"
    ],
    "Resource" : sort(flatten([
      var.grant_write_access_to_s3_arns,
      [for arn in var.grant_write_access_to_s3_arns : "${arn}/*"],
    ]))
  }] : []

  ecs-task-execution-policy-sqs-read = length(var.grant_read_access_to_sqs_arns) > 0 ? [{
    "Effect" : "Allow",
    "Action" : [
      "sqs:ReceiveMessage",
      "sqs:GetQueueAttributes"
    ],
    "Resource" : var.grant_read_access_to_sqs_arns
  }] : []

  ecs-task-execution-policy-sqs-write = length(var.grant_write_access_to_sqs_arns) > 0 ? [{
    "Effect" : "Allow",
    "Action" : [
      "sqs:SendMessage",
      "sqs:DeleteMessage",
      "sqs:SetQueueAttributes"
    ],
    "Resource" : var.grant_write_access_to_sqs_arns
  }] : []

  ecs-task-execution-policy-xray = var.enable_xray ? [{
    "Effect" : "Allow",
    "Action" : [
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups",
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets",
      "xray:GetSamplingStatisticSummaries",
      "ssm:GetParameters"
    ],
    "Resource" : "*"
  }] : []

  ecs-task-execution-custom-policies = length(var.custom_policies) > 0 ? var.custom_policies : []
}

resource "aws_iam_role_policy" "ecs-task-execution-policy" {
  name = "ecs-task-execution-policy"
  role = aws_iam_role.ecs-task-execution.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : concat(
      local.ecs-task-execution-policy-default,
      local.ecs-task-execution-policy-s3-read,
      local.ecs-task-execution-policy-s3-write,
      local.ecs-task-execution-policy-sqs-read,
      local.ecs-task-execution-policy-sqs-write,
      local.ecs-task-execution-policy-xray,
      local.ecs-task-execution-custom-policies
    )
  })
}

locals {
  kms_and_secret_arns = flatten([
    var.secrets_arns,
    var.kms_key_arns,
  ])
}

resource "aws_iam_role_policy" "ecs-task-execution-secrets-policy" {
  name = "ecs-task-execution-secrets-policy"
  role = aws_iam_role.ecs-task-execution.name

  policy = length(local.kms_and_secret_arns) > 0 ? jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetSecretValue",
          "kms:Decrypt",
          "kms:GenerateDataKey" # for writing to an encrypted S3 bucket
        ],
        "Resource" : local.kms_and_secret_arns,
      }
    ]
  }) : ""
}
