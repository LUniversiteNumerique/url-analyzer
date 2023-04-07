class Cleaner
  def initialize(filepath)
    @filepath = filepath
    @entries = []
  end

  def parse_output
    File.readlines(@filepath).each do |line|
      @entries.append(line) unless @entries.include?(line)
    end
  end

  def clean_output
    parse_output
    if !@entries.empty?
      File.truncate(@filepath, 0)
      @entries.each do |entry|
        file = File.open(@filepath, "a")
        file.puts entry
      end
    end
  end
end