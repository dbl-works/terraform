require 'aws-sdk-secretsmanager'
require 'aws-sdk-s3'
require 'net/http'
require 'json'
require 'stringio'

HTTP_OK = '200'
HTTP_REDIRECT = '302'

def http_request(uri, token)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri)
  request['Authorization'] = "token #{token}"
  http.request(request)
end

def call(event:, context:)
  s3_bucket = ENV.fetch('S3_BUCKET')
  secret_id = ENV.fetch('SECRET_ID')
  github_org = ENV.fetch('GITHUB_ORG')
  region = ENV.fetch('AWS_REGION', 'eu-central-1') # we should have this from AWS automatically

  secretsmanager = Aws::SecretsManager::Client.new(region: region)
  secret = secretsmanager.get_secret_value(secret_id: secret_id)
  config = JSON.parse(secret.secret_string)
  github_token = config.fetch('github_token')

  uri = URI("https://api.github.com/orgs/#{github_org}/repos")
  response = http_request(uri, github_token)
  raise "Failed to fetch repos: #{response.error}" unless response.code == HTTP_OK

  repos = JSON.parse(response.body)

  s3_client = Aws::S3::Client.new(region: region)

  # find a sample "repo" object at: github-backup/src/sample_response_repo.json
  repos.each do |repo|
    next if repo.fetch('fork', false) # forks are usually just some public gems, not our own code

    # Fetch repo data
    uri = URI("https://api.github.com/repos/#{github_org}/#{repo.fetch('name')}/zipball/#{repo.fetch('default_branch')}")
    response = http_request(uri, github_token)
    raise "Failed to fetch repo #{repo.fetch('name')}: #{response.error}" unless response.code == HTTP_REDIRECT

    # Download the repo zip file
    redirect_url = response.header.fetch('Location')
    uri = URI(redirect_url)
    response = http_request(uri, github_token)
    raise "Failed to fetch repo #{repo.fetch('name')}: #{response.error}" unless response.code == HTTP_OK

    # StringIO allows us to stream the file, which is more memory-efficient for large files
    zip_content = StringIO.new(response.body)

    s3_client.put_object(
      bucket: s3_bucket,
      key: "#{repo.fetch('name')}.zip",
      body: zip_content
    )
  end
end
