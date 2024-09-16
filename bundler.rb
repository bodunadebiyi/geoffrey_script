require_commands = ""
tmp_file = "bundled_tmp.rb"
bundled_file = "bundled.rb"
files_to_bundle = [
  "github_agent.rb",
  "errand_extractor.rb",
  "file_cleaner.rb",
  "task_executor.rb",
  "geoffrey.rb",
]


File.open(tmp_file, "w") do |file|
  files_to_bundle.each do |file_name|
    File.foreach(file_name) do |line|
      if /^require_relative/.match?(line.strip)
        next
      elsif /^require\s+/.match?(line.strip)
        require_commands += line
      else
        file.write(line)
      end
    end
    file.write("\n")
  end
end

# hoist all require commands to the top of the file
File.open(bundled_file, "w") do |file|
  file.write(require_commands)
  File.foreach(tmp_file) do |line|
    file.write(line)
  end
end

File.delete(tmp_file)
