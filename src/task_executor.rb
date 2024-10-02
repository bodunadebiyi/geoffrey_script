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

      print "cleanup_commands: #{cleanup_commands} \n"
      print "remind_commands: #{remind_commands} \n"

      remind_commands.each {|command| run_remind_command(command)} if remind_commands.any?
      run_cleanup_commands(cleanup_commands) if cleanup_commands.any?
    end
  end

  def run_remind_command(command_payload)
    puts "Reminding you in #{command_payload[:line]}"
  end

  def run_cleanup_commands(command_payloads)
    files = command_payloads.map { |command_payload| command_payload[:filename] }.uniq
    new_branch_name = get_new_branch_name
    system("git checkout -b #{new_branch_name}")
    update_files(command_payloads)
    puts "files updated..."

    system("git add #{files.join(' ')}")
    system("git commit -m 'Cleanup files'")
    system("git push origin #{new_branch_name}")

    puts "creating pull request..."

    system("gh pr create --base #{@github_agent.options[:current_branch]} --head #{new_branch_name} --title \"Cleanup files\" --body \"Cleanup files\"")
    system("git checkout #{@github_agent.options[:current_branch]}")
  end

  def grouped_and_partitioned
    @grouped_and_partitioned
  end

  def group_tasks_by_time_and_partition
    cleanup_synonyms = ['cleanup', 'delete', 'remove', 'delete file', 'remove file']
    grouped_tasks = @tasks.group_by { |task| task[:command][3]}
    grouped_tasks.keys.each do |time|
      @grouped_and_partitioned[time] = grouped_tasks[time].partition { |task| cleanup_synonyms.include?(task[:command][1])}
    end
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
    "geoffrey-cleanup-#{Time.now.to_i}"
  end

  def create_pull_request(branch_name)
    puts "creating pull request"
    @github_agent
      .set_head_branch(branch_name)
      .create_pull_request("Cleanup files", "Cleanup files")
  end
end
