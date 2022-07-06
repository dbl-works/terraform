variable "username" {
  type = string
}

variable "region" {
  type = string
}

variable "projects" {
  default = []
  type = set(object({
    name        = string
    environment = string
    region      = string
  }))
}

locals {
  projects = setunion([
    {
      environment = "staging",
      region      = var.region,
      project_tag = "staging-admin-access-projects"
    },
    {
      environment = "production",
      region      = var.region,
      project_tag = "production-admin-access-projects"
    }
    ],
    var.projects
  )
}
