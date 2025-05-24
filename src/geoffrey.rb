require_relative './github_agent'
require_relative './errand_extractor'
require_relative './command_validator'

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
    create_tickets_on_geoffrey_app
    return self
  end

  def validate_commands
    retrieve_tasks_from_pull_request
    run_validator

    return self
  end

  def retrieve_tasks_from_pull_request
    @files_changed = @github_agent.load_pull_request_files.pr_files
    print "Tasks data retrieved from PR... \n"
  end

  def extract_tasks
    @tasks = ErrandExtractor.new(@files_changed).run.errands
    print "Tasks extracted... \n"
  end

  def execute_tasks
    TaskExecutor.new(@github_agent, @tasks, @options[:actor]).execute_tasks
  end

  def run_validator
    CommandValidator.new(@files_changed, @github_agent).run
    print "File validation completed... \n"
  end

  def create_tickets_on_geoffrey_app
    print "Sending to Geoffrey app... \n"
  end
end
