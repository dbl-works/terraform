output "ecs_full_policy" {
  value = data.aws_iam_policy_document.ecs_full.json
}

