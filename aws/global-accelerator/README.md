# Terraform Module: Global Accelerator

A Global Accelerator to have a single entry point into a multi-region deployment with application loadbalancers for each region.


If you are using Cloudflare, set the DNS target for your API endpoint to the Global Accelerator endpoint (output as `dns_name`).


## Usage

```terraform
module "global-accelerator" {
  source = "github.com/dbl-works/terraform//aws/global-accelerator?ref=main"

  project            = "my-project"
  environment        = "production"

  load_balancers = [
    {
      region   = "eu-central-1"
      endpoint = "arn:aws:elasticloadbalancing:eu-central-1:${account_id}:loadbalancer/app/${project}-${environment}/xxx"
      weight   = 128
    },
    {
      region   = "us-east-1"
      endpoint = "arn:aws:elasticloadbalancing:us-east-1:${account_id}:loadbalancer/app/${ecs_name}/xxx"
      weight   = 128
    }
  ]

  # optional
  health_check_path = "/livez"
  health_check_port = 3000
  client_affinity   = "SOURCE_IP"
}
```



## Outputs
* `dns_name` - The DNS name of the accelerator. For example, `a5d53ff5ee6bca4ce.awsglobalaccelerator.com`.
* `ip_sets`
