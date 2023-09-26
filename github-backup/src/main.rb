require 'aws-sdk-secretsmanager'
require 'aws-sdk-s3'
require 'net/http'
require 'json'
require 'stringio'

HTTP_OK = '200'
HTTP_REDIRECT = '302'
PAGINATION_MAX_PAGES = 50 # 50 * 30 = 1500 repos max

def http_request(uri, token)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri)
  request['Authorization'] = "token #{token}"
  http.request(request)
end

def uri_to_next_page(response)
  # "<https://api.github.com/organizations/XXX/repos?page=2>; rel=\"next\", <https://api.github.com/organizations/XXX/repos?page=4>; rel=\"last\""
  link_header = response.header.fetch('link', nil)
  return unless link_header

  next_page = link_header&.split(',')&.find { |link| link.include?('rel="next"') }
  # it's important to set "uri_to_next_page" to nil if there is no next page for the while loop to stop
  return unless next_page

  next_page.split(';').first[/<(.*)>/, 1]
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
  raise "Failed to fetch repos: #{response.body}" unless response.code == HTTP_OK

  repos = JSON.parse(response.body)


  uri_to_next_page = uri_to_next_page(response)
  iterator = 0
  while uri_to_next_page
    break if iterator >= PAGINATION_MAX_PAGES
    iterator += 1
    raise 'Failed to find link to next page' unless uri_to_next_page

    uri = URI(uri_to_next_page)
    response = http_request(uri, github_token)
    raise "Failed to fetch repos: #{response.body}" unless response.code == HTTP_OK

    repos.concat(JSON.parse(response.body))
    uri_to_next_page = uri_to_next_page(response)
  end

  repos.uniq!

  s3_client = Aws::S3::Client.new(region: region)

  # find a sample "repo" object at: github-backup/src/sample_response_repo.json
  repos.each do |repo|
    next if repo.fetch('size') == 0 # empty repos can't be zipped & downloaded
    next if repo.fetch('fork', false) # forks are usually just some public gems, not our own code

    # Fetch repo data
    uri = URI("https://api.github.com/repos/#{github_org}/#{repo.fetch('name')}/zipball/#{repo.fetch('default_branch')}")
    response = http_request(uri, github_token)
    raise "Failed to fetch repo #{repo.fetch('name')}: #{response.body}" unless response.code == HTTP_REDIRECT

    # Download the repo zip file
    redirect_url = response.header.fetch('Location')
    uri = URI(redirect_url)
    response = http_request(uri, github_token)
    raise "Failed to fetch repo #{repo.fetch('name')}: #{response.body}" unless response.code == HTTP_OK

    # StringIO allows us to stream the file, which is more memory-efficient for large files
    zip_content = StringIO.new(response.body)

    s3_client.put_object(
      bucket: s3_bucket,
      key: "#{repo.fetch('name')}.zip",
      body: zip_content
    )
  end
end
