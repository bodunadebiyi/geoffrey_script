require 'net/http'
require 'json'

class GithubAgent
  attr_accessor :request_headers
  attr_accessor :head_branch

  GITHUB_BASE_URL = 'https://api.github.com'

  def initialize(options)
    @options = options
    @request_headers = {
      Accept: 'application/vnd.github+json',
      Connection: 'Keep-Alive',
      Authorization: "Bearer #{@options[:token]}"
    }
  end

  def load_pull_request_files
    uri = URI(pull_request_files_uri)
    res = Net::HTTP.get(uri, @request_headers)
    @pr_files = JSON.parse(res)
    self
  end

  def create_pull_request(title, body)
    raise StandardError.new("Head branch not set") unless @options[:head_branch]
    uri = URI(pull_request_uri)
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.body = {
      title: title,
      body: body,
      head: @options[:head_branch],
      base: @options[:base_branch]
    }
    req.initialize_http_header(@request_headers)
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    raise StandardError.new("Failed to create pull request") unless res.code.to_i >= 200 && res.code.to_i < 300
    self
  end

  def pr_files
    @pr_files
  end

  def set_head_branch(head_branch)
    @options[:head_branch] = head_branch
    self
  end

  def delete_ref(ref_name)
    uri = URI(delete_ref_uri(ref_name))
    req = Net::HTTP::Delete.new(uri, 'Content-Type' => 'application/json')
    req.initialize_http_header(@request_headers)
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    raise StandardError.new("Failed to delete ref") unless res.code.to_i >= 200 && res.code.to_i < 300
    self
  end

  def options
    @options
  end

  private

  def pull_request_files_uri
    "#{GITHUB_BASE_URL}/repos/#{options[:user]}/#{options[:repo]}/pulls/#{options[:pull_request_num]}/files"
  end

  def delete_ref_uri(ref_name)
    "#{GITHUB_BASE_URL}/repos/#{options[:user]}/#{options[:repo]}/git/refs/#{ref_name}"
  end

  def pull_request_uri
    "#{GITHUB_BASE_URL}/repos/#{options[:user]}/#{options[:repo]}/pulls"
  end

  def options=(options)
    @options = options
  end

  def pr_files=(pr_files)
    @pr_files = pr_files
  end

  def request_headers=(request_headers)
    @request_headers = request_headers
  end

  def request_headers
    @request_headers
  end
end
