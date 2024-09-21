require_relative './errand_extractor'

class FileCleaner
  attr_accessor :tmp_file
  attr_accessor :new_file
  attr_accessor :commands
  attr_accessor :line_number
  attr_accessor :within_cleanup_block
  attr_accessor :indentation_count
  attr_accessor :search_for_closing_block

  def initialize(tmp, new_file, commands)
    @tmp_file = tmp
    @new_file = new_file
    @commands = commands
    @within_cleanup_block = false
    @line_number = 1
    @indentation_count = nil
    @search_for_closing_block = false
    validate_commands
  end

  def validate_commands
    @commands.each do |command_payload|
      command = command_payload[:command]
      raise StandardError.new("Invalid command") if (command.length != 6 ||
        !ErrandExtractor.cleanup_commands.include?(command[1].downcase))
    end
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

  def get_intent(line)
    indentation_count = FileCleaner.get_indentation_count(line)
    is_closing_command = FileCleaner.is_closing_command?(line)
    line_contains_command = line_has_cleanup_command?(line) && !is_closing_command

    if line_contains_command && (@line_number == 1)
      remove_command_from_list(ErrandExtractor.parse_command(line))
      return :delete_file
    end

    if line_contains_command && !@within_cleanup_block
      command = ErrandExtractor.parse_command(line)
      remove_command_from_list(ErrandExtractor.parse_command(line))

      unless FileCleaner.is_inline_cleanup?(line)
        @identation_count = indentation_count
        @within_cleanup_block = true
        @search_for_closing_block = true if command[0] == '<'
      end
      return :skip_line
    end

    if @within_cleanup_block && @search_for_closing_block
      reset_state if is_closing_command
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

  def self.is_inline_cleanup?(line)
    ErrandExtractor.inline_command_regex.match?(line)
  end

  def self.is_closing_command?(line)
    ErrandExtractor.closing_command_regex.match?(line)
  end

  def line_has_cleanup_command?(line)
    return ErrandExtractor.has_command?(line) && !ErrandExtractor.is_closing_command?(line) && command_is_valid?(ErrandExtractor.parse_command(line))
  end

  def command_is_valid?(command)
    @commands.any?{|c| c[:command] == command}
  end

  def remove_command_from_list(command)
    @commands = @commands.filter{|c| c[:command] != command}
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
