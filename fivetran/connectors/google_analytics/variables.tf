variable "fivetran_group_id" {
  type        = string
  description = "Also know as external_id. Understand the group concept here: https://fivetran.com/docs/getting-started/powered-by-fivetran#createagroupusingtheui"
}

variable "google_profile_ids" {
  type        = list(string)
  description = "Specific User Profile IDs to sync. Must be populated if syncMode is set to SpecificAccounts"
}

variable "google_account_ids" {
  type        = list(string)
  description = "The list of specific Account IDs to sync. Must be populated if syncMode is set to SpecificAccounts."
}

variable "sync_frequency" {
  type        = number
  description = "Interval to sync that connector (min)"
  default     = 360
}

variable "project" {
  type = string
}

# THREE, SIX, TWELVE, TWENTY_FOUR and ALL_TIME
variable "timeframe_months" {
  type        = string
  description = "Number of months of reporting data you'd like to include in your initial sync. This cannot be modified once connection is created."
  default     = "ALL_TIME"
}

variable "auth" {
  type = object({
    client_id     = string # Client ID of your Google Analytics client application.
    client_secret = string # Client Secret of your Google Analytics client application.
    refresh_token = string # The long-lived Refresh token along with the client_id and client_secret parameters carry the information necessary to get a new access token for API resources.
  })
  default = null
}

variable "reports" {
  type = list(object({
    table           = string # Table name
    config_type     = string # Prebuilt, Custom
    prebuilt_report = string # List of prebuilt reports, https://fivetran.com/docs/applications/google-analytics/prebuilt-reports#prebuiltreports
  }))
  default = [
    {
      table           = "traffic"
      config_type     = "Prebuilt"
      prebuilt_report = "TRAFFIC"
    }
  ]
  description = "The list of reports. Each report corresponds to a table within the schema to which connector will sync the data"
}
