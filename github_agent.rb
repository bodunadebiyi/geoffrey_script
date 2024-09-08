require 'net/http'
require 'json'


class GithubAgent
  attr_accessor :request_headers

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

  def pr_files
    @pr_files
  end

  private

  def pull_request_files_uri
    "#{GITHUB_BASE_URL}/repos/#{options[:user]}/#{options[:repo]}/pulls/#{options[:pull_request_num]}/files"
  end

  def options=(options)
    @options = options
  end

  def options
    @options
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
