class TaskExecutor
  def initialize(github_agent, tasks, github_actor)
    @github_agent = github_agent
    @github_actor = github_actor
    @tasks = tasks
    @branch_created = false
  end

  def run
    execute_tasks
    create_pull_request_if_needed
  end

  def execute_tasks
    @tasks.keys.each do |filename|
      execute_tasks_for_file(filename, @tasks[filename])
    end
  end

  def execute_tasks_for_file(filename, command_payloads)
    cleanup_synonyms = ['cleanup', 'delete', 'remove', 'delete file', 'remove file']
    cleanup_commands, remind_commands = command_payloads.partition { |payload| cleanup_synonyms.include?(payload[:command][0])}
    remind_commands.each {|command| run_remind_command(filename, command[:command], command[:line])}
    run_cleanup_commands(filename, cleanup_commands) if cleanup_commands.any?
  end

  def run_remind_command(filename, command_parts, line)
    puts "Reminding you in #{line}"
  end

  def execute_commands(filename, line, commands)
    case commands[0]
    when 'cleanup',
          'delete',
          'remove',
          'delete file',
          'remove file'
      run_cleanup_command(filename, line)
    when 'remind'
      run_remind_command(filename, line)
    end
  end

  def run_cleanup_commands(filename, commands)
    create_branch_if_needed

    # update file here
  end

  private
  def new_branch_name
    "geoffrey-cleanup-#{File.basename(filename, File.extname(filename))}-#{Time.now.to_i}"
  end

  def create_pull_request_if_needed
    if @branch_created
      exec("git add .")
      exec("git commit -m 'Cleanup files'")
      exec("git push origin #{new_branch_name}")
      create_pull_request
    end
  end

  def create_branch_if_needed
    unless @branch_created
      exec("git checkout -b #{new_branch_name}")
      @branch_created = true
    end
  end

  def create_pull_request
    # create pull request
  end
end




# {
#   "app/controllers/application_controller.rb"=>[
#     {
#       :command=>["cleanup", "in", "2 weeks", "", ""],
#       :line=>"-46,4 +46,21"
#     },
#     {
#        :command=>["remind me", "in", "4 weeks", "to", "refactor this method"],
#        :line=>"-46,4 +46,21"
#     }],
#   "app/models/employee.rb"=>[
#     {:command=>["remove", "on", "2024-11-11", "", ""], :line=>"-0,0 +1,3"}
#   ]
# }
