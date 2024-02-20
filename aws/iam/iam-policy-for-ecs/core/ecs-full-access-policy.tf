data "aws_iam_policy_document" "ecs_full" {
  statement {
    sid = "AllowFullAccessToECS"
    actions = [
      "ecs:*",
    ]
    resources = flatten(concat(
      ["arn:aws:ecs:*:*:task-definition/*"],
      [
        for project in local.admin_access_projects : [
          "arn:aws:ecs:*:*:cluster/${project.name}",
          "arn:aws:ecs:*:*:container/${project.name}/*",
          "arn:aws:ecs:*:*:container-instance/${project.name}/*",
          "arn:aws:ecs:*:*:service/${project.name}/*",
          "arn:aws:ecs:*:*:task/${project.name}/*"
        ]
      ],
    ))
  }
}
