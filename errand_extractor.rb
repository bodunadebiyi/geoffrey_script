
class ErrandExtractor
  attr_accessor :state
  attr_accessor :errands

  COMMAND_REGEX = /<@\s*ge?off?rey\s*(remove|remind me|cleanup|delete|delete\s*file|remove\s*file)\s*(in|on|at)\s(.*?)(to|$)(.*)/i

  def initialize(file_changes)
    @file_changes = file_changes
    @errands = {}
    @state = {}
  end

  def get_errands
    @file_changes.each do |file|
      next unless (file["additions"] > 0) && (file["status"] == "modified" || file["status"] == "added")
      file["patch"].split("\n").each do |line|
        decision_engine(line, file['filename'])
      end
    end
    @errands
  end

  def decision_engine(line, filename)
    patch_line_info = capture(line, "@@", "@@")

    if patch_line_info[0]
      @state[:line_information] = patch_line_info[0]
      return
    end

    if /<@\s*ge?off?rey/.match?(line)
      begin
        if @errands[filename]
            @errands[filename] << {command: ErrandExtractor.parse_command(line), line: @state[:line_information]}
        else
          @errands[filename] = [{command: ErrandExtractor.parse_command(line), line: @state[:line_information]}]
        end
      rescue
        # do nothing
      end
      return
    end
  end

  def self.parse_command(raw_command_string)
    command = raw_command_string.scan(COMMAND_REGEX).flatten.map(&:strip)
    raise StandardError.new("Invalid command") unless command.length == 5
    return command
  end
end

def capture(text, starter, ender)
  text.scan(/#{starter}(.*?)#{ender}/).flatten.map(&:strip)
end
