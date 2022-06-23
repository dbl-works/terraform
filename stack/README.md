# Terraform Module: Stack

Launches all resources required to deploy and run an application using an ECS cluster, S3 bucket for the frontend, and Cloudflare for routing and DNS settings.

This includes:
- ECR, SSL certificates, secrets, RDS, ECS cluster, S3 buckets,..
- Cloudflare configuration to route `app.dbl.one` to the bucket's assets, setup DNS records for the app and api, ...


Launching a stack is a three-phase process:
(1) create all resources from [core](core/README.md) once per project (regardless of the number of environments/clusters).

(2) create all resources from [setup](setup/README.md) after "core" once for each enviroment.

(3) create all resources from [app][app/README.md] once for each environment.
