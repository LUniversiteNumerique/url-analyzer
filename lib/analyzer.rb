class Analyzer
  def initialize(file)
    @file = file
  end

  attr_accessor :file

  def traverse(obj, &blk)
    case obj
    when Hash
      obj.each {|k,v| traverse(v, &blk) }
    when Array
      obj.each {|v| traverse(v, &blk) }
    else
      blk.call(obj)
    end
  end

  def valid_url?(url)
    return false if url.to_s.include?("<script")
    url_regexp = /\A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix
    url.to_s =~ url_regexp ? true : false
  end

  def is_valid_status_code?(url_string)
    require "net/http"

    begin
      uri = URI(url_string.strip)
      return "Error" unless uri.host && uri.port
    rescue
      return "Error"
    end

    req = Net::HTTP.new(uri.host, uri.port)
    req.verify_mode = OpenSSL::SSL::VERIFY_PEER
    req.use_ssl = (uri.scheme == "https")

    begin
      res = req.request_head(uri)
      return curl_test(url_string, res.code) if res.code.to_i >= 400
    rescue
      begin
        req.verify_mode = OpenSSL::SSL::VERIFY_NONE
        res = req.request_head(uri)
        return curl_test(url_string, res.code) if res.code.to_i >= 400
      rescue
        return false
      end
    end
    
    return res.code unless ["200", "301", "302", "303", "307"].include?(res.code)

    false
  rescue Errno::ENOENT
    false
  end

  def curl_test(url, initial_code)
    begin
      curl = `curl -I #{url.strip}`
      return curl.lines.first.strip
    rescue
      return initial_code
    end
  end

  def start(output_file_path)
    output_file = File.open(output_file_path, "a")
    
    urls_array = []
    traverse(file) do |node|
      urls_array |= [node] if valid_url?(node)
    end

    urls_array.each do |url|
      status_code = is_valid_status_code?(url)
      puts "[#{status_code}]\t#{url}"
      output_file.puts "| #{url} | #{status_code} |" if status_code     
    end

    output_file.close unless output_file.nil?
  end
end
