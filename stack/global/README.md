# Terraform Module: Stack / Global

This launches resources required only once per Project. It includes the following resources:

- AWS Global Load Balancer (optional)
- IAM roles required only once, such as deploy-bot, role for auto-scaling, etc.
- Billing alerts
- automated regular backup of code from GitHub
- central buckets for: logging, terraform state, backups, etc.
- CloudTrail (optional)
