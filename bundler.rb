require_commands = ""
tmp_file = "geoffrey-script-tmp.rb"
bundled_file = "geoffrey-script.rb"
files_to_bundle = [
  "src/github_agent.rb",
  "src/errand_extractor.rb",
  "src/file_cleaner.rb",
  "src/task_executor.rb",
  "src/geoffrey.rb",
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
