require 'aws-sdk-iam'
require 'aws-sdk-secretsmanager'
require 'net/http'
require 'json'

API_BASE = 'https://circleci.com/api/v2'.freeze
ORG_ID = ENV.fetch('CIRCLE_CI_ORGANIZATION_ID')
CONTEXT_NAME = ENV.fetch('CONTEXT_NAME')
SECRET_ID = ENV.fetch('SECRET_ID')
AWS_REGION = ENV.fetch('AWS_REGION')

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
  uri = URI("#{API_BASE}/context/#{context_id}/environment-variable/#{env_var_name}")
  data = { value: env_var_value }
  request(uri, method: :put, data:)
end

def get_context_id(organization_id, context_name)
  uri = URI("#{API_BASE}/context?owner-id=#{organization_id}&owner-type=organization")
  items = request(uri).fetch('items')
  context = items.select { |item| item.fetch('name') == context_name }.first
  raise "Failed to fetch context: #{items}" unless context

  context.fetch('id')
end

def circleci_token
  @circleci_token ||= begin
    secretsmanager = Aws::SecretsManager::Client.new(region: AWS_REGION)
    secret = secretsmanager.get_secret_value(secret_id: SECRET_ID)
    config = JSON.parse(secret.secret_string)
    config.fetch('CIRCLE_CI_TOKEN')
  end
end

def renew_access_key(event:, context:)
  iam = Aws::IAM::Client.new
  user_name = ENV.fetch('USER_NAME')

  keys = iam.list_access_keys(user_name:).access_key_metadata

  context_id = get_context_id(ORG_ID, CONTEXT_NAME)
  new_key = iam.create_access_key(user_name:).access_key
  puts "Created new access key: #{new_key.access_key_id}"
  update_env(context_id, 'AWS_ACCESS_KEY_ID', new_key.access_key_id)
  update_env(context_id, 'AWS_SECRET_ACCESS_KEY', new_key.secret_access_key)

  old_access_key_ids = keys.map(&:access_key_id)
  old_access_key_ids.each do |access_key_id|
    iam.delete_access_key({ user_name:, access_key_id: })
    puts "Deleted old access key: #{access_key_id}"
  end
rescue Aws::IAM::Errors::ServiceError => e
  puts "IAM Error: #{e.message}"
end
