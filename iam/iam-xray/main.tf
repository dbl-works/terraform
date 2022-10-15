resource "aws_iam_group" "xray-view" {
  name = "xray-view"
}

resource "aws_iam_group_policy_attachment" "xray-view" {
  group      = aws_iam_group.xray-view.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayReadOnlyAccess" # managed by AWS
}
