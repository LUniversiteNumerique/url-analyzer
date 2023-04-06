class Cleaner
  def initialize(filepath)
    @filepath = filepath
    @entries = []
  end

  def parse_output
    File.readlines(@filepath).each do |line|
      url = line.split("|")[1]
      if url
        @entries.append(line) unless @entries.include?(line)
      else
        @entries.append(line)
      end
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