# Terraform Module: Stack

Launches all resources required to deploy and operate an application with a containerized backend and a compiled frontend.

This includes:

- Container Orchestration (ECS) and Container Registry (ECR) as well as all networking requied to run the containers (e.g. Load Balancer, VPC, Subnets, Security Groups, ...)
- DNS and CDN via Cloudflare and S3 for the frontend
- IAM Roles and Policies for the backend to access other AWS services
- Various supporting resources such as CloudTrail, GitHub backups, alerts, etc.

## Usage

Launch the module `stack/global` exactly once per project (regardless of the number of environments/clusters).

Launch the other modules `stack/setup`, `stack/core`, and `stack/app` once for each environment and project (e.g. "my-app", "staging").

## Details

The modules must be created in the following order:

### Stack Global

This launches resources required only once per Project. It includes the following resources:

- AWS Global Load Balancer (optional)
- IAM roles required only once, such as deploy-bot, role for auto-scaling, etc.
- Billing alerts
- automated regular backup of code from GitHub
- central buckets for: logging, terraform state, backups, etc.
- CloudTrail (optional)

### Stack Setup

This launches resources required once per environment. It includes the following resources:

- AWS Secrets Manager for secrets required for the setup of the environment
- Cloudflare
- static IPs
- DNS records and SSL certificates

### Stack Core

This launches resources required one per environment that must be created before the app can be
deployed. It includes the following resources:

- Container Registry (ECR)
- various IAM roles & policies

### Stack App

This launches all the resources required to deploy and operate the application. It includes the following resources:

- Container Orchestration (ECS)
- Networking (VPC, Subnets, Security Groups, Load Balancer, etc.)
- Databases (RDS, ElastiCache, etc.)
- VPC Peering (optional)

## Pre Requirements

In order to perform actions in Cloudflare, you must [create an API token](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/) with at least the following permissions:

- Zone | DNS | Edit
- Zone | Worker Routes | Edit
- Zone | Zone Settings | Edit

in the Zone Resources

- Include | Specific Zone | '${Your Zone}'
