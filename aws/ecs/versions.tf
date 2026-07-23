terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # aws_lb_listener mutual_authentication requires 5.30; passthrough-mode fix in 5.33
      version = ">= 5.34"
    }
  }
  required_version = ">= 1.0"
}
