variable "source_service" {
  type        = string
  description = "Name of the connector source: https://fivetran.com/docs/rest-api/connectors/config"
}

variable "destionation_service" {
  type        = string
  description = "Name for the destination type: https://fivetran.com/docs/rest-api/destinations/config"
}

# https://fivetran.com/docs/rest-api/destinations#payloadparameters
variable "region" {
  type        = string
  default     = "AWS_EU_CENTRAL_1"
  description = "Data processing location. This is where Fivetran will operate and run computation on data."
}

variable "time_zone_offset" {
  type        = string
  default     = "+2"
  description = "The time zone for the Fivetran sync schedule."
}

variable "destination_user_name" {
  type = string
}

variable "destination_password" {
  type = string
}

variable "destination_database_name" {
  type = string
}

variable "fivetran_group_id" {
  type = string
}
