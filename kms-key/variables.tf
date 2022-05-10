variable "environment" {}
variable "project" {}
variable "description" {}
variable "alias" {} # will be stored as alias/{project}/{environment}/{alias}

variable "deletion_window_in_days" { default = 30 }
