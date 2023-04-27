require "date"
require "yaml"
require "./lib/analyzer"
require "./lib/cleaner"

# Create the output file
output_file_path = "./output.md"

File.write(output_file_path, "") unless File.exist?(output_file_path)
File.truncate(output_file_path, 0)
output_file = File.open(output_file_path, "a")
output_file.puts "| URL         | Code        |"
output_file.puts "| ----------- | ----------- |"
output_file.close

# Parse the files
dir = "./parcours-hybridation"
files = Dir.glob("#{dir}/**/*.yml") do | file |
  yamlfile = YAML.load_file(file)
  analyzer = Analyzer.new yamlfile
  analyzer.start(output_file_path)
end

cleaner = Cleaner.new output_file_path
cleaner.clean_output

output_file = File.open(output_file_path, "a")
output_file.puts "\nDate : #{DateTime.now()}"
