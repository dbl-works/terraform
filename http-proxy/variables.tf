variable "project" {
  type        = string
  description = "Name of the project, used for tagging."
}

variable "environment" {
  type        = string
  description = "Name of the environment, used for tagging."
}

variable "public_key" {
  type        = string
  description = "SSH public key used for the initial setup."
}

variable "public_subnet_id" {
  type        = string
  description = "ID of the public subnet in which the instance will be placed."
  validation {
    condition     = can(regex("^subnet-[0-9a-f]{8,17}$", var.public_subnet_id))
    error_message = "public_subnet_id must be a valid subnet ID."
  }
}

variable "ami_id" {
  type        = string
  default     = "ami-0502e817a62226e03" # ubuntu 20.04 which has a free quota
  description = "ID of the AMI to use for the instance."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC in which resources reside that may use the proxy."
  validation {
    condition     = can(regex("^vpc-[0-9a-f]{8,17}$", var.vpc_id))
    error_message = "vpc_id must be a valid VPC ID."
  }
}

variable "cidr_block" {
  type        = string
  description = "value of the cidr block of the VPC in which resources reside that may use the proxy."
  validation {
    condition     = can(regex("^(\\d{1,3}\\.){3}\\d{1,3}/\\d{1,2}$", var.cidr_block))
    error_message = "cidr_block must be a valid CIDR block."
  }
}

variable "eip" {
  type        = string
  default     = null
  description = "Elastic IP to associate with the instance. If omitted, a new one is created."
  validation {
    condition     = can(regex("^(\\d{1,3}\\.){3}\\d{1,3}$", var.eip))
    error_message = "eip must be a valid IPv4 address."
  }
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ssh_enabled" {
  type        = bool
  default     = false
  description = "Enable SSH for the initial configuration of the instance, then disable it again."
}

variable "egress_rules" {
  description = "List of objects representing egress rules"
  type = list(object({
    port        = number
    protocol    = optional(string, "tcp")
    cidr_blocks = optional(list(string), ["0.0.0.0/0"])
  }))
  default = [
    {
      port        = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]
}
