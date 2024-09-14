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
