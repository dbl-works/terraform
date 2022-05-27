# This does not cover the Tag and iam management
# resource "aws_iam_policy" "developer-usage-for-taggable-resources" {
#   name        = "TaggableResourcesDeveloperUsage"
#   path        = "/"
#   description = "Allow developers to have list + read access level in the project"

#   policy = <<EOF
# {
#   "Effect": "Allow",
#   "Resource": "*",
#   "Action": [
#     "*:Describe*",
#     "*:Get*",
#     "*:List*",
#     "*:Search*"
#   ],
#   "Condition":{
#       "StringLike":{
#           "aws:ResourceTag/Project":"&{aws:PrincipalTag/${var.environment}-developer-access-projects}"
#       }
#       "StringEqual":{
#           "aws:ResourceTag/Environment": ${var.environment}
#       }
#   },
# },
# EOF
# }

# "rds:Describe*",
# "rds:Get*",
# "rds:List*"
# "ec2:Describe*",
# "ec2:Get*",
# "ec2:Search*",
# "ecr:BatchGet*",
# "ecr:Describe*",
# "ecr:Get*",
# "ecr:List*",
