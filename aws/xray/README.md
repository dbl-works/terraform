# Terraform Module: Xray

A repository for setting up Xray group and sampling.
NOTE: The Xray group and sampling is shared within the whole region so this module only need to be run once in each region.

## Usage

```terraform
module "xray" {
  source = "github.com/dbl-works/terraform//aws/xray?ref=main"

  # optional
  response_time_threshold = 0.2
  duration_threshold      = 0.25
}
```

You will need to grant access to non-admin users, see [iam/xray](../iam/iam-xray/README.md).
