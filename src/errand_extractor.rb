class ErrandExtractor
  attr_accessor :state
  attr_accessor :errands

  OTHER_COMMANDS = ["remider", "remind me"]
  CLEANUP_COMMANDS = ["cleanup", "remove", "delete", "remove file"]
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
      next unless ErrandExtractor.valid_file_change(file)
      file["patch"].split("\n").each do |line|
        decision_engine(line, file['filename'])
      end
    end
    return self
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

  def self.valid_file_change(file_change)
    file_change["additions"] > 0 && (file_change["status"] == "modified" || file_change["status"] == "added") && !file_change["filename"].match?(/geoffrey-script/i)
  end

  def self.parse_command(raw_command_string)
    command = raw_command_string.scan(COMMAND_REGEX).flatten.map(&:strip)
    command_validty = check_command_validity(command)

    if command_validty.any?
      raise StandardError.new(command_validty.join(", "))
    end

    return command
  end

  def self.check_command_validity(command_component)
    invalid_reasons = []
    invalid_reasons << "Invalid command" if command_component.length != 6
    invalid_reasons << "Incorrect prequal tag for command, should be '<'" if !["", "<"].include?(command_component[0])
    invalid_reasons << "Invalid instruction. Use remove, remind or cleanup" if ![*CLEANUP_COMMANDS, *OTHER_COMMANDS].include?(command_component[1].downcase)
    invalid_reasons << "Invalid time instruction. Use in, on or at" if !['in', 'on', 'at'].include?(command_component[2].downcase)
    invalid_reasons << "Invalid time format" if !command_component[3].match?(/\d+-\d+-\d+|\d+\s*(days?|weeks?|months?|hours?|minutes?|seconds?|years?)/)

    return invalid_reasons
  end

  def self.is_inline_cleanup?(line)
    IS_INLINE_COMMAND_REGEX.match
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

  def self.cleanup_commands
    CLEANUP_COMMANDS
  end

  def self.is_closing_command?(text)
    CLOSING_COMMAND_REGEX.match?(text)
  end
end
