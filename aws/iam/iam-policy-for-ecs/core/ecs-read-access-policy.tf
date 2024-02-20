data "aws_iam_policy_document" "ecs_read" {
  statement {
    sid = "AllowReadAccessToECS"
    actions = [
      "ecs:Describe*",
      "ecs:Get*",
      "ecs:List*"
    ]
    resources = flatten(concat(
      ["arn:aws:ecs:*:*:task-definition/*"],
      [
        for project in local.developer_access_projects : [
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
