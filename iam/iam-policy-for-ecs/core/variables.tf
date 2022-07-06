variable "username" {
  type = string
}

variable "region" {
  type = string
}

variable "projects" {
  default = []
  type    = set(object())
}

locals {
  projects = setunion([
    {
      name        = null,
      environment = "staging",
      region      = var.region,
      project_tag = "staging-admin-access-projects"
    },
    {
      name        = null,
      environment = "production",
      region      = var.region,
      project_tag = "production-admin-access-projects"
    }
    ],
    var.projects
  )
}
