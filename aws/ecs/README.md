# Terraform Module: ECS Cluster

Create a compute cluster for hosting docker based apps.

## Notes

The `idle_timeout` is set to 60 seconds. Ensure that your webserver's keep-alive timeout is set to 60 seconds (or more) to prevent the load balancer from keeping connections open to the already closed server.

When using Rails with Puma, the default timeout is 20 seconds. This can be changed by setting the `persistent_timeout` option in `config/puma.rb`.

For better security, add the WAF module.

## Usage

```terraform
resource "aws_alb_target_group" "facebook" {
  name        = "${local.project}-${local.environment}-facebook"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = module.vpc.id
  target_type = "ip"

  health_check {
    path                = "/livez"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 25
    interval            = 30
    matcher             = "200,301,302,401,403,404"
  }

  tags = {
    Project     = local.project
    Environment = local.environment
  }
}

module "ecs" {
  source = "github.com/dbl-works/terraform//ecs?ref=v2021.07.05"

  project            = local.project
  environment        = local.environment
  vpc_id             = module.vpc.id
  subnet_public_ids  = module.vpc.subnet_public_ids

  # optional
  secrets_arns                = []
  kms_key_arns                = []
  health_check_path           = "/healthz"
  health_check_options        = {
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 30
    interval            = 60
    matcher             = "200,204"
  }
  certificate_arn             = module.ssl-certificate.arn # requires a `certificate` module to be created separately
  regional                    = true
  keep_alive_timeout          = 60
  additional_certificate_arns = [
    {
      name = "my-second-domain.test"
      arn  = module.ssl-certificate-second-domain.arn
    }
  ]

  allow_internal_traffic_to_ports = []
  allow_alb_traffic_to_ports = [5000]
  alb_listener_rules = [
    {
      priority         = 1
      type             = "forward"
      target_group_arn = aws_alb_target_group.facebook.arn
      path_pattern     = ["/facebook/*"]
      host_header      = []
    }
  ]

  allowlisted_ssh_ips = [
    local.cidr_block,
    "XX.XX.XX.XX/32", # e.g. a VPN
  ]

  grant_read_access_to_s3_arns  = []
  grant_write_access_to_s3_arns = []

  grant_read_access_to_sqs_arns = []
  grant_write_access_to_sqs_arns = []

  custom_policies = []
  enable_xray     = true
  autoscale_metrics_map = {
    web = {
      ecs_min_count = 2 # Optional, default value is 1
      ecs_max_count = 4 # Optional, default value is 30
      metrics = [
        {
          metric_name    = "CPUUtilization"
          statistic      = "Average"
          threshold_up   = 50
          threshold_down = 30
        },
        {
          metric_name    = "MemoryUtilization"
          statistic      = "Average"
          threshold_up   = 50
          threshold_down = 30
        }
      ]
    },
    sidekiq = {
      ecs_max_count = 4
      metrics = [
        {
          metric_name    = "CPUUtilization"
          statistic      = "Average"
          threshold_up   = 50
          threshold_down = 30
        },
        {
          metric_name    = "MemoryUtilization"
          statistic      = "Average"
          threshold_up   = 50
          threshold_down = 30
        }
      ]
    }
  }
  autoscale_params = {
    alarm_evaluation_periods      = 5
    alarm_period                  = 60 # seconds
    datapoints_to_alarm_up        = 3
    datapoints_to_alarm_down      = 3
    cooldown                      = 300 # seconds
    scale_up_adjustment           = 1
    scale_up_lower_bound          = 0
    scale_down_adjustment         = -1
    scale_down_upper_bound        = 0
    ecs_autoscale_role_arn        = "arn:aws:iam::123456789:role/ecs-autoscale"
    sns_topic_arn                 = "arn:aws:sns:us-east-1:175743622168:slack-sns"
    scale_down_treat_missing_data = "breaching"
    scale_up_treat_missing_data   = "missing"
  }

  # WAF
  waf_acl_arn  = null # see module aws/waf

  # Access Logs, stored in S3
  # see: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html
  enable_access_logs = false
  access_logs_bucket = ""
  access_logs_prefix = "lb-logs"
}
```

`allow_internal_traffic_to_ports` allow traffic to given ports within the cluster, e.g. to call an internal service like a PDF renderer.



## Health checks

If you run apps in many different cloud environments (e.g. Heroku, RKE, EKS, ECS, Lambda, Cloud66), you want consistent health checks implemented for consistency.

Kubernetes have an excellent methodology where they name their health check `/livez` and `/readyz` to not conflict with any other potential resource endpoint.
The below documentation mentions `/healthz` (and this is also what we used previoulsy) but since Kubernetes 1.16 deprecated this endpoint, this terminology will be phased out.

[https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-liveness-http-request](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-liveness-http-request)

We should aim to have the following endpoint(s) implemented on all projects to work across any deployed environment:

- `GET /livez`
- `GET /readyz` (optional, but useful for some projects)
