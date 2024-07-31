require "colorize"

require "./parser"
require "./option"
require "./file_record"
require "./digest"

module CheckSum
  class App
    getter parser : Parser
    getter option : Option

    def initialize
      @option = Option.new
      @parser = Parser.new(@option)

      @n_total = 0
      @n_success = 0
      @n_mismatch = 0
      @n_error = 0

      # It is used to clear the line
      # true if the cursor is at the beginning of the line
      @cleared_flag = true

      @exit_code = 0
    end

    def run
      @option = parser.parse(ARGV)
      case option.action
      when Action::Calculate
        main_run_calculate
      when Action::Check
        main_run_check
      when Action::Version
        print_version
      when Action::Help
        print_help
      else
        print_help
      end
      exit(@exit_code)
    rescue ex
      error_message = "[checksum] ERROR: #{ex.class} #{ex.message}"
      error_message += "\n#{ex.backtrace.join("\n")}" if CheckSumError.debug
      STDERR.puts error_message
      exit(1)
    end

    def main_run_calculate
      elapsed_time = Time.measure do
        option.filenames.each do |filename|
          main_run_calculate(filename)
        end
      end

      if option.verbose
        STDERR.puts "[checksum] (#{format_time_span(elapsed_time)})".colorize(:dark_gray)
      end
    end

    def main_run_calculate(filename : String)
      filename = File.expand_path(filename) if option.absolute_path
      algorithm = option.algorithm

      # - If the file does not exist, it should not be calculated

      unless File.exists?(filename)
        raise FileNotFoundError.new(filename)
      end

      case File.info(filename).type
      when File::Type::Directory
        # If the file is a directory, it should not be calculated
        # Recursive calculation of files in the directory should be
        # achieved with wildcards.
        raise IsADirectoryError.new(filename)
      when File::Type::Symlink
        STDERR.puts "#{filename} is a symbolic link"
        # If the file is a symlink, it should not be calculated ?
        # should this return nil or raise an error?
      end
      record = calculate_checksum(filename, algorithm)
      puts record.to_s
    end

    def calculate_checksum(filename : String, algorithm : Algorithm) : FileRecord
      d = Digest.new(algorithm)
      s = d.hexfinal_file(filename)
      d.reset
      FileRecord.new(s, Path[filename])
    end

    def main_run_check
      option.filenames.each do |filename|
        main_run_check(filename)
      end
    end

    def main_run_check(filename : String)
      results = nil
      elapsed_time = Time.measure do
        filename = File.expand_path(filename) if option.absolute_path
        algorithm = option.algorithm
        if algorithm == Algorithm::AUTO
          algorithm = Digest.guess_algorithm(filename)
        end
        records = parse_checksum_file(filename)
        puts "#{records.size} files in #{filename.colorize.bold}"
        if option.verbose
          puts "[checksum] Guessed algorithm: #{algorithm}".colorize(:dark_gray)
        end
        Dir.cd(File.dirname(filename)) do
          results = verify_checksums(records, algorithm)
        end
      end
      print_result(results, elapsed_time) unless results.nil?
    end

    # Read the checksum file and parse each line into records
    def parse_checksum_file(filename)
      records = [] of FileRecord
      File.open(filename) do |file|
        file.each_line do |line|
          sum, path = line.chomp.split
          records << FileRecord.new(sum, Path[path])
        end
      end
      records
      # rescue
      #  raise CheckSumError.new("Failed to read the checksum file: #{filename}")
    end

    def verify_checksum(filepath, expected_hash_value, digest)
      begin
        actual_hash_value = digest.hexfinal_file(filepath)
      rescue e
        # FIXME
      end
    end

    record Result1, index : Int32, filepath : (String | Path), expected : String?, actual : String?, error : Exception?

    # Verify the MD5 checksums of the files
    def verify_checksums(records : Array(FileRecord), algorithm : Algorithm)
      @n_total = records.size
      @n_success = 0
      @n_mismatch = 0
      @n_error = 0

      {% if flag?(:preview_mt) %}
        channel = Channel(Result1).new(16)
      {% else %}
        # When multi-threading support is disabled
        # the `digest` object will be reused for each file
        digest = Digest.new(algorithm)
      {% end %}

      records.each_with_index do |file_record, index|
        filepath = file_record.filepath
        expected_hash_value = file_record.checksum
        actual_hash_value = nil
        error = nil

        # Try to make use of the parallelism
        # `shards build --release -Dpreview_mt`
        # CRYSTAL_WORKERS=16 bin/checksum -c checksum.md5

        {% if flag?(:preview_mt) %}
          spawn do
            # If you create a new Digest object outside the spawn block
            # and use, reset and reuse it for each file,
            # you will get the following error:
            #   Digest::FinalizedError: finish already called
            # when you enable multi-threading support. (preview_mt)
            # This may be because the `Digest` object is not thread-safe.

            digest = Digest.new(algorithm)
            begin
              actual_hash_value = digest.hexfinal_file(filepath)
            rescue e
              error = e
              # Do not need to reset the digest object
              # because it will be created again for the next file
            end

            r1 = Result1.new(index, filepath, expected_hash_value, actual_hash_value, error)

            channel.send(r1)
          end
        {% else %}
          begin
            actual_hash_value = digest.hexfinal_file(filepath)
          rescue e
            error = e
          ensure
            # Reset the digest object
            digest.reset
          end

          r1 = Result1.new(index, filepath, expected_hash_value, actual_hash_value, error)

          count_and_print_message(r1)
        {% end %}
      end

      # Wait for all the results
      # FIXME: https://forum.crystal-lang.org/t/6936

      {% if flag?(:preview_mt) %}
        @n_total.times do
          r = channel.receive
          count_and_print_message(r)
        end
      {% end %}

      return {
        total:    @n_total,
        success:  @n_success,
        mismatch: @n_mismatch,
        error:    @n_error,
      }
    end

    def count_and_print_message(r1)
      filepath = r1.filepath
      filepath = File.expand_path(filepath) if option.absolute_path

      index = r1.index
      total = @n_total
      expected_hash_value = r1.expected
      actual_hash_value = r1.actual
      error = r1.error

      if error
        print_error_message(filepath, index, total, error)
        @exit_code = 1
        @n_error += 1
      elsif expected_hash_value == actual_hash_value
        print_ok_message(filepath, index, total)
        @n_success += 1
      else
        print_mismatch_message(filepath, index, total, expected_hash_value, actual_hash_value)
        @exit_code = 1
        @n_mismatch += 1
      end

      # Flush the output
      STDOUT.flush
    end

    def print_ok_message(filepath, index, total)
      print_clear_the_line
      print format_file_number(index, total)
      print "OK".colorize(:green)
      print ":\t"
      print filepath
      @cleared_flag = false
    end

    def print_mismatch_message(filepath, index, total, expected_hash_value, actual_hash_value)
      print_clear_the_line
      print format_file_number(index, total)
      print "Mismatch Error".colorize(:red)
      print ":\t"
      print filepath

      # Check if file is or very small
      # This is useful when the file is empty
      case File.size(filepath)
      when 0..100
        print "\t"
        print "(#{File.size(filepath)} bytes)".colorize(:dark_gray)
      end

      puts

      if option.verbose
        puts " expected: #{expected_hash_value}".colorize(:dark_gray)
        puts " actual:   #{actual_hash_value}".colorize(:dark_gray)
      end
      @cleared_flag = true
    end

    def print_error_message(filepath, index, total, error)
      print_clear_the_line
      print format_file_number(index, total)
      print "#{error.class}".colorize(:magenta)
      print ":\t"
      puts filepath
      if option.verbose
        puts " #{error.message}".colorize(:dark_gray)
      end
      @cleared_flag = true
    end

    def print_result(result, elapsed_time)
      print_clear_the_line

      # Print the result
      print "#{result[:total]}"
      print " files"
      print ", "
      if result[:success].zero?
        print "#{result[:success]} success"
      else
        print "#{result[:success]} success".colorize(:green)
      end
      print ", "
      if result[:mismatch].zero?
        print "#{result[:mismatch]} mismatch"
      else
        print "#{result[:mismatch]} mismatch".colorize(:red)
      end
      print ", "
      if result[:error].zero?
        print "#{result[:error]} errors"
      else
        print "#{result[:error]} errors".colorize(:magenta)
      end

      # Print the elapsed time
      print "  (#{format_time_span(elapsed_time)})"

      puts
    end

    def print_version
      puts "checksum #{VERSION}"
      {% if flag?(:preview_mt) %}
        puts "  with multi-threading support"
      {% end %}
    end

    def print_help
      puts parser.help
    end

    private def format_file_number(index, total)
      total_digits = total.to_s.size
      formatted_index = (index + 1).to_s.rjust(total_digits, ' ')
      "(#{formatted_index}/#{total}) "
    end

    private def print_clear_the_line
      return if @cleared_flag
      if option.clear_line
        print("\x1b[2K\r")
      else
        puts
      end
    end

    private def format_time_span(span : Time::Span)
      total_seconds = span.total_seconds
      if total_seconds < 60
        return "#{total_seconds.round(2)} seconds"
      end

      minutes = span.total_minutes
      seconds = span.seconds
      "#{"%d" % minutes.floor}:#{seconds < 10 ? "0" : ""}#{seconds} minutes"
    end
  end
end
