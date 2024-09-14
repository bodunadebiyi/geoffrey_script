
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
