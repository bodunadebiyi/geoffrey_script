require 'optparse'
require_relative './geoffrey'

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

  opts.on("-b", "--base-branch BASE", "Base branch") do |b|
    options[:base_branch] = b
  end

  opts.on("-c", "--current-branch CURRENT", "Current branch") do |c|
    options[:current_branch] = c
  end

  opts.on("-s", "--sha SHA", "Latest SHA") do |s|
    options[:sha] = s
  end

  opts.on("-e", "--run-action RUNACTION", "Run action") do |e|
    options[:run_action] = e
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!

def validate_options options
  raise StandardError.new("Missing required options") unless options[:repo] && options[:user] && options[:pull_request_num] && options[:token] && options[:actor]
end

validate_options(options)

if options[:run_action] == "validate"
  print "Geoffrey command validator has started... \n"
  Geoffrey.new(options).validate_commands
elsif options[:run_action] == "run"
  print "Geoffrey runner has started... \n"
  Geoffrey.new(options).run
else
  print "Invalid action specified. Exiting... \n"
end
