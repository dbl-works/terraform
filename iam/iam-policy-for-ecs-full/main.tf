data "aws_iam_policy_document" "ecs_full" {
  statement {
    sid = "AllowWriteAccessToECS"
    actions = [
      "ecs:*",
    ]
    resources = flatten(concat(
      ["arn:aws:ecs:*:*:task-definition/*"],
      [
        for project_name in var.project_names : [
          "arn:aws:ecs:*:*:cluster/${project_name}",
          "arn:aws:ecs:*:*:container/${project_name}/*",
          "arn:aws:ecs:*:*:container-instance/${project_name}/*",
          "arn:aws:ecs:*:*:service/${project_name}/*",
          "arn:aws:ecs:*:*:task/${project_name}/*"
        ]
      ],
    ))
  }
}
