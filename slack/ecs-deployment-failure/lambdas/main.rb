require 'json'
require 'net/http'

FAILURE_EVENT_NAME = 'SERVICE_DEPLOYMENT_FAILED'.freeze

def handler(event:, context:)
  puts "[INFO] #{event}"
  puts "[INFO] Context: #{context}"
  event_name = event.fetch('detail').fetch('eventName')

  return unless deployment_failure?(event_name)

  resource_name = event.fetch('resources').join(',')
  region = event.fetch('region')
  reason = event.fetch('detail').fetch('reason')

  post_to_slack(resource_name, region, reason)
end

def deployment_failure?(event_name)
  event_name == FAILURE_EVENT_NAME
end

def post_to_slack(resource_name, region, reason)
  webhook_url = ENV['SLACK_WEBHOOK_URL']
  uri = URI(webhook_url)

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Post.new(
    uri.path,
    { 'Content-Type' => 'application/json' }
  )
  request.body = payload.to_json

  http.request(request)
end

def payload
  {
    "blocks": [
      {
        "type": "header",
        "text": {
          "type": "plain_text",
          "text": ":warning: Deployment Failrue",
          "emoji": true
        }
      },
      {
        "type": "section",
        "text": {
          "type": "plain_text",
          "text": "Resource in region",
          "emoji": true
        }
      },
      {
        "type": "actions",
        "elements": [
          {
            "type": "button",
            "text": {
              "type": "plain_text",
              "text": "View logs",
              "emoji": true
            },
            "value": "click_me_123"
          }
        ]
      }
    ]
  }
end
