require 'aws-sdk-iam'
require 'aws-sdk-secretsmanager'
require 'net/http'
require 'json'

CIRCLECI_API_BASE = 'https://circleci.com/api/v2'.freeze
CIRCLECI_ORG_ID = ENV.fetch('CIRCLECI_ORG_ID')
CIRCLECI_CONTEXT_NAME = ENV.fetch('CIRCLECI_CONTEXT_NAME')

AWS_SECRET_ID = ENV.fetch('AWS_SECRET_ID')
AWS_USER_NAME = ENV.fetch('AWS_USER_NAME')
AWS_REGION = ENV.fetch('AWS_REGION') # set by AWS for the lambda

def handler(event:, context:)
  iam = Aws::IAM::Client.new
  keys = iam.list_access_keys(user_name: AWS_USER_NAME).access_key_metadata
  new_key = iam.create_access_key(user_name: AWS_USER_NAME).access_key

  puts "Created new access key: #{new_key.access_key_id}"
  update_env(context_id, 'AWS_ACCESS_KEY_ID', new_key.access_key_id)
  update_env(context_id, 'AWS_SECRET_ACCESS_KEY', new_key.secret_access_key)

  old_access_key_ids = keys.map(&:access_key_id)
  old_access_key_ids.each do |access_key_id|
    iam.delete_access_key({ user_name: AWS_USER_NAME, access_key_id: access_key_id })
    puts "Deleted old access key: #{access_key_id}"
  end
rescue Aws::IAM::Errors::ServiceError => e
  puts "IAM Error: #{e.message}"
end

private

def request(uri, method: :get, data: nil)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Object.const_get("Net::HTTP::#{method.capitalize}").new(uri)
  request['Circle-Token'] = circleci_token
  request.content_type = 'application/json'
  request.body = JSON.dump(data) if data

  response = http.request(request)
  raise "Error: #{response.code} - #{response.body}" unless response.is_a?(Net::HTTPSuccess)

  JSON.parse(response.body)
end

def update_env(context_id, env_var_name, env_var_value)
  uri = URI("#{CIRCLECI_API_BASE}/context/#{context_id}/environment-variable/#{env_var_name}")
  data = { value: env_var_value }
  request(uri, method: :put, data:)
end

def context_id
  @context_id ||= begin
    uri = URI("#{CIRCLECI_API_BASE}/context?owner-id=#{CIRCLECI_ORG_ID}&owner-type=organization")
    items = request(uri).fetch('items')
    context = items.select { |item| item.fetch('name') == CIRCLECI_CONTEXT_NAME }.first
    raise "Failed to fetch context: #{items}" unless context

    context.fetch('id')
  end
end

def circleci_token
  @circleci_token ||= begin
    secretsmanager = Aws::SecretsManager::Client.new(region: AWS_REGION)
    secret = secretsmanager.get_secret_value(secret_id: AWS_SECRET_ID)
    config = JSON.parse(secret.secret_string)
    config.fetch('CIRCLECI_TOKEN')
  end
end
