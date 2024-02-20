variable "username" {
  type = string
}

variable "project_access" {
  type = map(any)
}

variable "allow_listing_s3" {
  type    = bool
  default = true
}
