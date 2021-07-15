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

resource "aws_iam_role_policy" "ecs-task-execution-policy" {
  name = "ecs-task-execution-policy"
  role = aws_iam_role.ecs-task-execution.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
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
          "ecs:DescribeTasks"
        ],
        "Resource" : "*"
      }
    ]
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
