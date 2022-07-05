output "ecs_read_policy" {
  value = data.aws_iam_policy_document.ecs_read.json
}

