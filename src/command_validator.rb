require_relative './errand_extractor'

class CommandValidator
  def initialize(file_changes, github_agent)
    @file_changes = file_changes
    @github_agent = github_agent
    @files_with_invalid_commands = []
    @invalid_command_reasons = ''
  end

  def run
    @file_changes.each do |file|
      next unless ErrandExtractor.valid_file_change(file)
      file["patch"].split("\n").each do |line|
        get_files_with_invalid_command(line, file['filename'])
      end
    end
    push_invalid_command_to_message_to_pr
  end

  def get_files_with_invalid_command(line, filename)
    @files_with_invalid_commands << {filename: filename, line: line} if contains_invalid_command?(line)
  end

  def contains_invalid_command?(line)
    return false unless ErrandExtractor.has_command?(line)
    begin
      ErrandExtractor.parse_command(line)
      return false
    rescue => e
      @invalid_command_reasons = e.message
      return true
    end
  end

  def push_invalid_command_to_message_to_pr
    print "files with invalid commands:: ", @files_with_invalid_commands if @files_with_invalid_commands.any?
    @files_with_invalid_commands.each do |file|
      line_number = 1
      File.foreach(file[:filename]) do |line|
        send_note_to_pr(file[:filename], line_number) if contains_invalid_command?(line)
        line_number += 1
      end
    end
  end

  def send_note_to_pr(filename, line_number)
    puts "Sending note to PR"
    @github_agent.pr_review_comment(error_message, line_number - 1, line_number, filename)
  end

  def error_message
    @invalid_command_reasons + "\n" +
    "We do not understand this Geoffrey command. Please enter the correct syntax. \nValid Command Example: `@geoffrey <cleanup|remind|delet|remove> <in|at|on> 2 <hours|weeks|days|months|years>`"
  end
end
