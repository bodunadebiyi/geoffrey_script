require_relative './errand_extractor'

class FileCleaner
  def initialize(tmp, new_file, commands)
    @tmp_file = tmp
    @new_file = new_file
    @commands = commands
    @line_number = 1
    @prev_line = nil
    @state = initial_state
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

    File.open(@new_file, 'a') do |file|
      File.foreach(@tmp_file) do |line|
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

    File.delete(@new_file) if should_delete_file
  end

  def setup_block_cleanup(command, curr_indentation_count)
    update_state(:within_cleanup_block, true)
    update_state(:search_for_closing_block, command[0] == '<')
    update_state(:block_indentation_count, curr_indentation_count)
  end

  def get_intent_dep(line)
    curr_indentation_count = FileCleaner.get_indentation_count(line)
    is_closing_command = FileCleaner.is_closing_command?(line)
    line_contains_command = line_has_cleanup_command?(line) && !is_closing_command
    return [curr_indentation_count, is_closing_command, line_contains_command]
  end

  def get_intent(line)
    result = :do_nothing
    curr_indentation_count, is_closing_command, line_contains_command = get_intent_dep(line)
    return :delete_file if line_contains_command && (@line_number == 1) # everything halts

    # we just found a command
    if line_contains_command && !@state[:within_cleanup_block]
      reset_state
      command = ErrandExtractor.parse_command(line)
      remove_command_from_list(ErrandExtractor.parse_command(line))
      setup_block_cleanup(command, curr_indentation_count) if !FileCleaner.is_inline_cleanup?(line)
      result = :skip_line
    elsif @state[:within_cleanup_block] && @state[:search_for_closing_block]
      reset_state if is_closing_command
      result = :skip_line
    elsif @state[:within_cleanup_block] && !@state[:search_for_closing_block]
      if curr_indentation_count > @state[:block_indentation_count]
        update_state(:went_up_a_level_within_block, true)
        result = :skip_line
      elsif curr_indentation_count < @state[:block_indentation_count]
        result = close_cleanup_block
      elsif curr_indentation_count == @state[:block_indentation_count]
        if line.strip.empty?
          result = :skip_line
        elsif !@state[:went_up_a_level_within_block]
          result = :skip_line
        elsif @state[:went_up_a_level_within_block] && @prev_line.strip.empty?
          result = close_cleanup_block
        elsif @state[:went_up_a_level_within_block] && !@prev_line.strip.empty?
          result = :skip_line
          reset_state
        end
      else
        result = :skip_line
      end
    else
      result = :do_nothing
    end

    @prev_line = line
    return result
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
    @state = initial_state
  end

  def initial_state
    {
      within_cleanup_block: false,
      block_indentation_count: nil,
      search_for_closing_block: false,
      went_up_a_level_within_block: false
    }
  end

  def update_state(key, value)
    @state[key] = value
  end

  def close_cleanup_block
    reset_state
    :do_nothing
  end
end
