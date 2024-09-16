require 'net/http'
require 'json'
require 'optparse'


class GithubAgent
  attr_accessor :request_headers
  attr_accessor :base_branch
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

  private

  def pull_request_files_uri
    "#{GITHUB_BASE_URL}/repos/#{options[:user]}/#{options[:repo]}/pulls/#{options[:pull_request_num]}/files"
  end

  def pull_request_uri
    "#{GITHUB_BASE_URL}/repos/#{options[:user]}/#{options[:repo]}/pulls"
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

class FileCleaner
  attr_accessor :tmp_file
  attr_accessor :new_file
  attr_accessor :commands
  attr_accessor :line_number

  def initialize(tmp, new_file, commands)
    @tmp_file = tmp
    @new_file = new_file
    @commands = commands
    @within_cleanup_block = false
    @line_number = 0
    @indentation_count = nil
    @search_for_closing_block = false
  end

  def run
    should_delete_file = false

    File.open(new_file, 'a') do |file|
      File.foreach(tmp_file) do |line|
        intent = get_intent(line)
        @line_number += 1

        case intent
        when :delete_file
          should_delete_file = true
          break
        when :do_nothing
          file.write(line)
        when :skip_line
          next
        end
      end
    end

    File.delete(new_file) if should_delete_file
  end

  def get_intent_(line)
    indentation_count = FileCleaner.get_indentation_count(line)
    line_contains_command = line_has_cleanup_command?(line)

    if line_contains_command && @line_number == 1
      remove_command_from_list(ErrandExtractor.parse_command(line))
      return :delete_file
    end

    if line_contains_command && !@within_cleanup_block
      command = ErrandExtractor.parse_command(line)
      remove_command_from_list(ErrandExtractor.parse_command(line))

      unless is_inline_cleanup?(line)
        @identation_count = indentation_count
        @within_cleanup_block = true
        @search_for_closing_block = true if command[0] == '<'
      end
      return :skip_line
    end

    if @within_cleanup_block && @search_for_closing_block
      if ErrandExtractor.closing_command_regex.match?(line)
        reset_state
      end
      return :skip_line
    end

    if @within_cleanup_block && !@search_for_closing_block
      if indentation_count > @indentation_count && !line.strip.empty?
        return :skip_line
      else
        reset_state unless line.strip.empty?
        return :do_nothing
      end
    end

    return :do_nothing
  end

  def is_inline_cleanup?(line)
    ErrandExtractor.inline_command_regex.match?(line)
  end

  def line_has_cleanup_command?(line)
    return ErrandExtractor.has_command?(line) && command_is_valid?(ErrandExtractor.parse_command(line))
  end

  def command_is_valid?(command)
    @commands.any?{|c| c[:command] == command}
  end

  def remove_command_from_list(command)
    @commands = @commands.filtter{|c| c[:command] != command}
  end

  def self.get_indentation_count(line)
    return line.scan(/^\s*/).first.length
  end

  def reset_state
    @within_cleanup_block = false
    @indentation_count = nil
    @search_for_closing_block = false
  end
end

class TaskExecutor
  def initialize(github_agent, tasks, github_actor)
    @github_agent = github_agent
    @github_actor = github_actor
    @tasks = tasks
    @branch_created = false
    @grouped_and_partitioned = {}
  end

  def execute_tasks
    group_tasks_by_time_and_partition
    @grouped_and_partitioned.keys.each do |time|
      cleanup_commands = @grouped_and_partitioned[time][0]
      remind_commands = @grouped_and_partitioned[time][1]

      remind_commands.each {|command| run_remind_command(command)} if remind_commands.any?
      run_cleanup_commands(cleanup_commands) if cleanup_commands.any?
    end
  end

  def run_remind_command(command_payload)
    puts "Reminding you in #{command_payload[:line]}"
  end

  def run_cleanup_commands(command_payloads)
    branch_name = get_new_branch_name
    exec("git checkout -b #{branch_name}")

    update_files(command_payloads)

    exec("git commit -m 'Cleanup files'")
    exec("git push origin #{branch}")
    TaskExecutor.create_pull_request(branch_name)
  end

  private

  def update_files(command_payloads)
    command_payloads.group_by { |command_payload| command_payload[:filename] }.each do |filename, commands|
      file_basename = File.basename(filename, File.extname(filename))
      tmp_file = filename.gsub(file_basename, "#{file_basename}-tmp")

      File.rename(filename, tmp_file)
      FileCleaner.new(tmp_file, filename, commands).run
      File.delete(tmp_file)
    end
  end

  def get_new_branch_name
    "geoffrey-cleanup-}-#{Time.now.to_i}"
  end

  def self.create_pull_request(branch_name)
    github_agent
      .set_head_branch(branch_name)
      .create_pull_request("Cleanup files", "Cleanup files")
  end

  def group_tasks_by_time_and_partition
    cleanup_synonyms = ['cleanup', 'delete', 'remove', 'delete file', 'remove file']
    grouped_tasks = @tasks.group_by { |task| task[:time] }
    grouped_tasks.keys.each do |time|
      @grouped_and_partitioned[time] = grouped_tasks[time].partition { |task| cleanup_synonyms.include?(task[:command][0])}
    end
  end
end

# [{filename: "app/controllers/application_controller.rb", command: ["cleanup", "in", "2 weeks", "", ""], line: "-46,4 +46,21", time: 2.weeks},
# {filename: "app/controllers/application_controller.rb", command: ["remind me", "in", "4 weeks", "to", "refactor this method"], line: "-46,4 +46,21", time: 4.weeks},
# {filename: "app/models/employee.rb", command: ["remove", "on", "2024-11-11", "", ""], line: "-0,0 +1,3", time: "2024-11-11"}]


class ErrandExtractor
  attr_accessor :state
  attr_accessor :errands

  COMMAND_REGEX = /(<?)@\s*ge?off?rey\s*(remove|remind me|remider|cleanup|delete|remove\s*file)\s*(in|on|at)\s(.*?)(to|$)(.*)/i
  CONTAINS_COMMAND_REGEX = /<?@\s*ge?off?rey[^>]/i
  CLOSING_COMMAND_REGEX = /@\s*ge?off?rey\s*>/i
  IS_INLINE_COMMAND_REGEX = /\w+\.*\W*.*<?@\s*ge?off?rey[^>]/i

  def initialize(file_changes)
    @file_changes = file_changes
    @errands = []
    @state = {}
  end

  def run
    @file_changes.each do |file|
      next unless (file["additions"] > 0) && (file["status"] == "modified" || file["status"] == "added")
      file["patch"].split("\n").each do |line|
        decision_engine(line, file['filename'])
      end
    end
  end

  def decision_engine(line, filename)
    patch_line_info = ErrandExtractor.capture(line, "@@", "@@")

    if patch_line_info[0]
      @state[:line_information] = patch_line_info[0]
      return
    end

    if CONTAINS_COMMAND_REGEX.match?(line)
      begin
        @errands << {filename: filename, command: ErrandExtractor.parse_command(line), line: @state[:line_information]}
      rescue
        print "Failed to parse command: #{line}"
      end
      return
    end
  end

  def self.parse_command(raw_command_string)
    command = raw_command_string.scan(COMMAND_REGEX).flatten.map(&:strip)
    raise StandardError.new("Invalid command") unless command.length == 6
    return command
  end

  def self.capture_command_regex
    COMMAND_REGEX
  end

  def self.contains_command_regex
    CONTAINS_COMMAND_REGEX
  end

  def self.closing_command_regex
    CLOSING_COMMAND_REGEX
  end

  def self.inline_command_regex
    IS_INLINE_COMMAND_REGEX
  end

  def self.capture(text, starter, ender)
    text.scan(/#{starter}(.*?)#{ender}/).flatten.map(&:strip)
  end

  def self.has_command?(text)
    CONTAINS_COMMAND_REGEX.match?(text)
  end
end


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

