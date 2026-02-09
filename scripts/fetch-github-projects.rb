#!/usr/bin/env ruby
# Fetch GitHub Pinned Repositories Script
# Uses GitHub GraphQL API to retrieve pinned repos and update _data/projects.yml

require 'net/http'
require 'json'
require 'yaml'
require 'time'

# Configuration
GITHUB_USERNAME = ENV['GITHUB_USERNAME'] || 'DataNeuron'
GITHUB_TOKEN = ENV['GITHUB_TOKEN'] || ENV['PORTFOLIO_SYNC_TOKEN']
OUTPUT_FILE = File.join(__dir__, '..', '_data', 'projects.yml')
GRAPHQL_ENDPOINT = 'https://api.github.com/graphql'

# GitHub GraphQL Query
QUERY = <<~GRAPHQL
  query GetPinnedRepositories($username: String!) {
    user(login: $username) {
      pinnedItems(first: 6, types: REPOSITORY) {
        totalCount
        edges {
          node {
            ... on Repository {
              id
              name
              description
              url
              homepageUrl
              stargazerCount
              forkCount
              primaryLanguage {
                name
                color
              }
              createdAt
              updatedAt
              repositoryTopics(first: 10) {
                nodes {
                  topic {
                    name
                  }
                }
              }
              isArchived
              isFork
            }
          }
        }
      }
    }
  }
GRAPHQL

def log_info(message)
  puts "[INFO] #{Time.now.strftime('%Y-%m-%d %H:%M:%S')} - #{message}"
end

def log_error(message)
  $stderr.puts "[ERROR] #{Time.now.strftime('%Y-%m-%d %H:%M:%S')} - #{message}"
end

def fetch_pinned_repos
  # Validate token exists
  if GITHUB_TOKEN.nil? || GITHUB_TOKEN.empty?
    raise 'GITHUB_TOKEN environment variable is not set. Please set it before running this script.'
  end

  log_info "Fetching pinned repositories for #{GITHUB_USERNAME}..."

  uri = URI(GRAPHQL_ENDPOINT)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Post.new(uri.path, {
    'Authorization' => "bearer #{GITHUB_TOKEN}",
    'Content-Type' => 'application/json',
    'User-Agent' => 'DataNeuron-Portfolio-Sync/1.0'
  })

  request.body = {
    query: QUERY,
    variables: { username: GITHUB_USERNAME }
  }.to_json

  # Make HTTP request with error handling
  begin
    response = http.request(request)
    body = JSON.parse(response.body)

    # Check for HTTP errors
    unless response.is_a?(Net::HTTPSuccess)
      error_msg = body['message'] || "HTTP #{response.code}: #{response.message}"
      log_error "GitHub API returned error: #{error_msg}"
      return { 'errors' => [{ 'message' => error_msg }] }
    end

    body
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    log_error "Network timeout: #{e.message}"
    { 'errors' => [{ 'message' => "Network timeout: #{e.message}" }] }
  rescue SocketError => e
    log_error "Network error: #{e.message}"
    { 'errors' => [{ 'message' => "Network error: #{e.message}" }] }
  rescue JSON::ParserError => e
    log_error "Invalid JSON response: #{e.message}"
    { 'errors' => [{ 'message' => "Invalid JSON response from GitHub API" }] }
  rescue => e
    log_error "Unexpected error: #{e.class} - #{e.message}"
    { 'errors' => [{ 'message' => "Unexpected error: #{e.message}" }] }
  end
end

def transform_response(response)
  timestamp = Time.now.utc.iso8601

  # Check for errors
  if response['errors']
    error_message = response['errors'].first['message']
    log_error "Failed to fetch: #{error_message}"

    return {
      'fetch_metadata' => {
        'last_updated' => timestamp,
        'fetch_status' => 'error',
        'error_message' => error_message,
        'source' => 'github',
        'github_username' => GITHUB_USERNAME
      },
      'projects' => []
    }
  end

  # Extract pinned items
  pinned_items = response.dig('data', 'user', 'pinnedItems', 'edges') || []

  if pinned_items.empty?
    log_info "No pinned repositories found for #{GITHUB_USERNAME}"
  else
    log_info "Found #{pinned_items.length} pinned repositories"
  end

  # Transform each repository
  projects = pinned_items.map do |edge|
    node = edge['node']

    # Extract topics
    topics = node.dig('repositoryTopics', 'nodes')&.map { |t| t.dig('topic', 'name') } || []

    {
      'id' => node['id'],
      'name' => node['name'],
      'full_name' => "#{GITHUB_USERNAME}/#{node['name']}",
      'description' => node['description'],
      'url' => node['url'],
      'homepage_url' => node['homepageUrl'],
      'language' => node['primaryLanguage'] ? {
        'name' => node['primaryLanguage']['name'],
        'color' => node['primaryLanguage']['color']
      } : nil,
      'stars' => node['stargazerCount'],
      'forks' => node['forkCount'],
      'created_at' => node['createdAt'],
      'updated_at' => node['updatedAt'],
      'topics' => topics,
      'is_archived' => node['isArchived'],
      'is_fork' => node['isFork']
    }
  end

  {
    'fetch_metadata' => {
      'last_updated' => timestamp,
      'fetch_status' => 'success',
      'error_message' => nil,
      'source' => 'github',
      'github_username' => GITHUB_USERNAME
    },
    'projects' => projects
  }
end

def write_yaml_file(data)
  log_info "Writing data to #{OUTPUT_FILE}..."

  # Create directory if it doesn't exist
  output_dir = File.dirname(OUTPUT_FILE)
  Dir.mkdir(output_dir) unless Dir.exist?(output_dir)

  # Atomic write: write to temp file, then rename
  temp_file = "#{OUTPUT_FILE}.tmp"

  begin
    File.write(temp_file, YAML.dump(data))
    File.rename(temp_file, OUTPUT_FILE)
    log_info "✅ Successfully wrote #{data['projects'].length} projects to #{OUTPUT_FILE}"
  rescue => e
    log_error "Failed to write file: #{e.message}"
    File.delete(temp_file) if File.exist?(temp_file)
    raise
  end
end

# Main execution
begin
  log_info "Starting GitHub projects fetch..."

  response = fetch_pinned_repos
  data = transform_response(response)
  write_yaml_file(data)

  if data['fetch_metadata']['fetch_status'] == 'success'
    log_info "✅ Fetch completed successfully"
    log_info "Projects updated: #{data['projects'].length}"
    exit 0
  else
    log_error "❌ Fetch completed with errors"
    log_error "Error: #{data['fetch_metadata']['error_message']}"
    exit 1
  end
rescue => e
  log_error "Fatal error: #{e.class} - #{e.message}"
  log_error e.backtrace.join("\n")
  exit 1
end
