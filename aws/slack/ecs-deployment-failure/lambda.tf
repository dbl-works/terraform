locals {
  lambda_function_name = "${var.project}-${var.environment}-deployment-monitoring"
}

# Sample Event:
# {
#   "version": "0",
#   "id": "af0835c5-401a-44a8-7d94-99effc34dc29",
#   "detail-type": "ECS Deployment State Change",
#   "source": "aws.ecs",
#   "account": "xxxxxxxxxxxx",
#   "time": "2022-07-20T11:09:36Z",
#   "region": "eu-central-1",
#   "resources": [
#     "arn:aws:ecs:eu-central-1:xxxxxxxxxxxx:service/project-staging/web"
#   ],
#   "detail": {
#     "eventType": "INFO",
#     "eventName": "SERVICE_DEPLOYMENT_COMPLETED",
#     "deploymentId": "ecs-svc/4231880795355584839",
#     "updatedAt": "2022-07-20T11:08:21.049Z",
#     "reason": "ECS deployment ecs-svc/4231880795355584839 completed."
#   }
# }
# Check here for the samples of deployment events => https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_cwe_events.html#ecs_service_deployment_events

module "lambda" {
  source = "../../lambda"

  function_name = local.lambda_function_name

  project     = var.project
  environment = var.environment
  source_dir  = "${path.module}/lambdas"

  # optional
  handler     = "main.handler"
  timeout     = var.timeout
  memory_size = var.memory_size
  runtime     = var.runtime
  environment_variables = {
    SLACK_WEBHOOK_URL = var.slack_webhook_url
  }
}
