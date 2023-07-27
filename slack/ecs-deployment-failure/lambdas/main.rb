require 'json'
require 'net/http'

FAILED_EVENT = 'SERVICE_DEPLOYMENT_FAILED'.freeze

def handler(event:)
  puts "[INFO] #{event}"
  event_name = event.fetch('detail').fetch('eventName')
  return unless event_name == FAILED_EVENT

  resource_name = event.fetch('resources').join(',')
  region = event.fetch('region')
  reason = event.fetch('detail').fetch('reason')
  _, cluster_name, service_name = resource_name.split('/')
  puts "[INFO] Cluster Name: #{cluster_name}, Service Name: #{service_name}, Region: #{region}, Reason: #{reason}"

  response = post_to_slack(cluster_name, service_name, region, reason)
  puts "[INFO] Response: #{response.body}"
end

def deployment_failure?(event_name)
  event_name == FAILURE_EVENT_NAME
end

def post_to_slack(cluster_name, service_name, region, reason)
  uri = URI(ENV.fetch('SLACK_WEBHOOK_URL'))
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Post.new(
    uri.path,
    { 'Content-Type' => 'application/json' }
  )
  request.body = payload(cluster_name, service_name, region, reason).to_json
  http.request(request)
end

def payload(cluster_name, service_name, region, reason)
  {
    "blocks": [
      {
        "type": 'header',
        "text": {
          "type": 'plain_text',
          "text": ':warning: Deployment Failure',
          "emoji": true
        }
      },
      {
        "type": 'section',
        "text": {
          "type": 'mrkdwn',
          "text": "*Cluster*: #{cluster_name}"
        }
      },
      {
        "type": 'section',
        "text": {
          "type": 'mrkdwn',
          "text": "*Service*: #{service_name}"
        }
      },
      {
        "type": 'section',
        "text": {
          "type": 'mrkdwn',
          "text": "*Region*: #{region}"
        }
      },
      {
        "type": 'section',
        "text": {
          "type": 'mrkdwn',
          "text": "*Reason*: #{reason}"
        }
      }
    ],
    "attachments": [
      {
        "fallback": 'Link to the AWS Console',
        "actions": [
          {
            "type": 'button',
            "name": 'log_button',
            "text": 'View Deployment',
            "url": ecs_url(cluster_name, service_name, region),
            "style": 'primary'
          }
        ]
      }
    ]
  }
end

def ecs_url(cluster_name, service_name, region)
  "https://#{region}.console.aws.amazon.com/ecs/v2/clusters/#{cluster_name}/services/#{service_name}/deployments?region=#{region}"
end
