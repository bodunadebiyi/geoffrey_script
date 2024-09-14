require 'optparse'
require_relative './github_agent'
require_relative './errand_extractor'

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: hyena.rb [options]"

  opts.on("-r", "--repo REPO", "Github repo to act on") do |f|
    options[:repo] = f
  end

  opts.on("-u", "--user USER", "Github user to act as") do |u|
    options[:user] = u
  end

  opts.on("-p", "--pull-request-num PNUM", "pull request number") do |p|
    options[:pull_request_num] = p
  end

  opts.on("-g", "--github-token TOKEN", "Github Token") do |o|
    options[:token] = o
  end

  opts.on("-a", "--github-actor ACTOR", "Github Actor") do |a|
   options[:actor] = a
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!

class Geoffrey
  attr_accessor :options
  attr_accessor :files_changed
  attr_accessor :tasks

  def initialize(options)
    @options = options
    @github_agent = GithubAgent.new(@options)
  end

  def run
    retrieve_tasks_from_pull_request
    extract_tasks
    execute_tasks
    return self
  end

  def retrieve_tasks_from_pull_request
    @files_changed = github_agent.load_pull_request_files.pr_files
  end

  def extract_tasks
    @tasks = ErrandExtractor.new(@files_changed).run.errands
  end

  def execute_tasks
    TaskExecutor.new(@github_agent, @tasks, @options[:actor]).execute_tasks
  end
end

def validate_options options
  raise StandardError.new("Missing required options") unless options[:repo] && options[:user] && options[:pull_request_num] && options[:token] && options[:actor]
end

validate_options(options)




gman = Geoffrey.new(options)
gman.files_changed = test_payload
gman.extract_tasks
print gman.tasks
