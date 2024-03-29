require 'json'
require 'net/http'
require 'uri'

def text_block_from(finding_counts)
  if finding_counts.fetch('CRITICAL', 0) != 0
    { 'color' => 'danger', 'icon' => ':red_circle:' }
  elsif finding_counts.fetch('HIGH', 0) != 0
    { 'color' => 'warning', 'icon' => ':large_orange_diamond:' }
  else
    { 'color' => 'good', 'icon' => ':green_heart:' }
  end
end

def build_slack_message(event)
  channel = ENV.fetch('CHANNEL')

  account_id = event.fetch('account')
  detail = event.fetch('detail')
  region = event.fetch('region')
  repository_name = detail.fetch('repository-name')
  severity_counts = detail.fetch('finding-severity-counts')
  image_digest = detail.fetch('image-digest')

  message = "*ECR Image Scan findings | #{region} | Account ID:#{account_id}*"
  text_properties = text_block_from(severity_counts)

  {
    'username' => 'Amazon ECR',
    'channels' => channel,
    'icon_emoji' => ':ecr:',
    'text' => message,
    'attachments' => [
      {
        'fallback' => 'AmazonECR Image Scan Findings Description.',
        'color' => text_properties.fetch('color'),
        'title' => "#{text_properties.fetch('icon')} #{repository_name}:#{detail.fetch('image-tags', [])[0]}",
        'title_link' => "https://#{region}.console.aws.amazon.com/ecr/repositories/#{repository_name}/_/image/#{image_digest}/scan-results?region=#{region}",
        'text' => "Image Scan Completed at #{event.fetch('time')}",
        'fields' => severity_counts.map do |severity_level, count|
                      { 'title' => severity_level.capitalize, 'value' => count, 'short' => true }
                    end
      }
    ]
  }
end

def lambda_handler(event:, context:)
  # Sample responses
  # {
  #   "version": "0",
  #   "id": "85fc3613-e913-7fc4-a80c-a3753e4aa9ae",
  #   "detail-type": "ECR Image Scan",
  #   "source": "aws.ecr",
  #   "account": "123456789012",
  #   "time": "2019-10-29T02:36:48Z",
  #   "region": "us-east-1",
  #   "resources": [
  #       "arn:aws:ecr:us-east-1:123456789012:repository/my-repo"
  #   ],
  #   "detail": {
  #       "scan-status": "COMPLETE",
  #       "repository-name": "my-repo",
  #       "finding-severity-counts": {
  #          "CRITICAL": 10,
  #          "MEDIUM": 9
  #        },
  #       "image-digest": "sha256:7f5b2640fe6fb4f46592dfd3410c4a79dac4f89e4782432e0378abcd1234",
  #       "image-tags": ["commit-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"]
  #   }
  # }
  #
  slack_message = build_slack_message(event)
  uri = URI(ENV.fetch('WEBHOOK_URL'))
  req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
  req.body = slack_message.to_json

  begin
    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end
    puts('Message posted.')
  rescue StandardError => e
    puts("Request failed: #{e.message}")
  end
end
