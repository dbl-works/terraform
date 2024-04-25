variable "resource_group_name" {
  type = string
}

variable "region" {
  type = string
}

variable "project" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = null
}

variable "network_watcher_name" {
  type    = string
  default = null
}
