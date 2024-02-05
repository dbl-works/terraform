# Terraform Module: Fivetran Google Analytics

### NOTES
If auth credentials are not passed in, you need to log in to the Fivetran UI and manually authorize a Google Account to sync data from Google Analytics

### Example
Set up google analytics in fivetran

```
terraform {
  required_providers {
    fivetran = {
      source  = "fivetran/fivetran"
      version = "~> 1.0"
    }
  }

  required_version = ">= 1.0"
}

variable "fivetran_api_key" {
  type = string
}

variable "fivetran_api_secret" {
  type = string
}

provider "fivetran" {
  api_key    = var.fivetran_api_key    # $ export TF_VAR_fivetran_api_key=<api-key>
  api_secret = var.fivetran_api_secret # $ export TF_VAR_fivetran_api_secret=<api-secret>
}
```

```
module "google_analytics" {
  source = "github.com/dbl-works/terraform//fivetran/connectors/google_analytics?ref=v2022.07.05"
  providers = {
    # Have to specified the provider because fivetran is not from hashicorp
    fivetran = fivetran
  }

  fivetran_group_id       = "fivetran-group-id" # Also know as external_id. Understand the group concept here: https://fivetran.com/docs/getting-started/powered-by-fivetran#createagroupusingtheui
  project                 = "meta"              # connector name shown on Fivetran UI, i.e. "google_analytics_${var.project}"
  google_profile_ids      = ["xxxxxxx"] # Specific User Profile IDs to sync. Must be populated if syncMode is set to SpecificAccounts
  google_account_ids      = ["xxxxxxx"] # The list of specific Account IDs to sync. Must be populated if syncMode is set to SpecificAccounts.

  # optional
  sync_frequency = 360 # Interval to sync that connector (min)
  timeframe_months = "ALL_TIME" # Number of months of reporting data you'd like to include in your initial sync. This cannot be modified once connection is created.
  # Refer to this to obtain auth: https://www.ibm.com/docs/en/app-connect/cloud?topic=gmail-connecting-google-application-by-providing-credentials-app-connect-use-basic-oauth
  auth = {
    client_id     = "xxxxxxx" # Client ID of your Google Analytics client application.
    client_secret = "xxxxxxx" # Client Secret of your Google Analytics client application.
    refresh_token = "xxxxxxx" # The long-lived Refresh token along with the client_id and client_secret parameters carry the information necessary to get a new access token for API resources.
  }
  reports = [
    {
      table           = "traffic"  # Table name
      config_type     = "Prebuilt" # Prebuilt, Custom
      prebuilt_report = "TRAFFIC"  # List of prebuilt reports, https://fivetran.com/docs/applications/google-analytics/prebuilt-reports#prebuiltreports
    }
  ]
}
```
