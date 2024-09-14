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
