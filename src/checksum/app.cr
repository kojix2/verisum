require "colorize"
{% if flag?(:term_screen) %}
  require "term-screen"
{% end %}

require "./parser"
require "./option"
require "./file_record"
require "./digest"

module CheckSum
  class App
    getter parser : Parser
    getter option : Option

    EXIT_SUCCESS = 0
    EXIT_FAILURE = 1

    @screen_width : Int32

    def initialize
      @option = Option.new
      @parser = Parser.new(@option)

      @n_total = 0
      @n_success = 0
      @n_mismatch = 0
      @n_error = 0

      @screen_width = ENV.fetch("COLUMNS", "80").to_i
      # Term::Screen.width.to_i # tput cols

      @exit_code = EXIT_SUCCESS
    end

    def run
      @option = parser.parse(ARGV)
      case option.action
      when Action::Calculate
        run_calculate
      when Action::Check
        run_check
      when Action::Version
        print_version
      when Action::Help
        print_help
      else
        print_help
      end
      exit(@exit_code)
    rescue ex
      STDERR.puts "[checksum] ERROR: #{ex.class} #{ex.message}".colorize(:red).bold
      STDERR.puts "\n#{ex.backtrace.join("\n")}" if CheckSumError.debug?
      exit(1)
    end

    def run_calculate
      elapsed_time = Time.measure do
        option.filenames.each do |filename|
          run_calculate(filename)
        end
      end

      if option.verbose?
        STDERR.puts "[checksum] (#{format_time_span(elapsed_time)})".colorize(:dark_gray)
      end
    end

    def run_calculate(filename : String)
      filename = resolve_filepath(filename)
      algorithm = option.algorithm

      # - If the file does not exist, it should not be calculated

      unless filename == "-" # stdin
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
      end
      record = calculate_checksum(filename, algorithm)
      puts record.to_s
    end

    def run_check
      option.filenames.each do |filename|
        run_check(filename)
      end
    end

    def run_check(filename : String)
      results = nil
      elapsed_time = Time.measure do
        filename = resolve_filepath(filename)
        records = parse_checksum_file(filename)
        algorithm = option.algorithm
        if algorithm == Algorithm::AUTO
          algorithm =
            case records.first.checksum
            when /^[0-9a-f]{32}$/  then Algorithm::MD5
            when /^[0-9a-f]{40}$/  then Algorithm::SHA1
            when /^[0-9a-f]{64}$/  then Algorithm::SHA256
            when /^[0-9a-f]{128}$/ then Algorithm::SHA512
            else
              raise CheckSumError.new("Unknown algorithm")
            end
        end
        puts "#{records.size} files in #{filename.colorize.bold}"
        if option.verbose?
          puts "[checksum] Guessed algorithm: #{algorithm}".colorize(:dark_gray)
        end
        Dir.cd(File.dirname(filename)) do
          results = verify_file_checksums(records, algorithm)
        end
      end
      print_result(results, elapsed_time) unless results.nil?
    end

    def calculate_checksum(filename : String, algorithm : Algorithm) : FileRecord
      d = Digest.new(algorithm)
      s = d.hexfinal(filename == "-" ? STDIN : filename)
      d.reset
      FileRecord.new(s, Path[filename])
    end

    # Read the checksum file and parse each line into records
    def parse_checksum_file(filename) : Array(FileRecord)
      if filename == "-"
        parse_lines(STDIN)
      else
        File.open(filename) do |file|
          parse_lines(file)
        end
      end
    end

    private def parse_lines(io : IO) : Array(FileRecord)
      io.each_line.map do |line|
        next if line =~ /^\s*#/ # Skip comment lines
        sum, path = line.chomp.split
        FileRecord.new(sum, Path[path])
      end.to_a.compact
    end

    # Verify the MD5 checksums of the files
    def verify_file_checksums(records : Array(FileRecord), algorithm : Algorithm)
      @n_total = records.size
      @n_success = 0
      @n_mismatch = 0
      @n_error = 0

      digest = Digest.new(algorithm)

      last_update_col_time = Time.utc

      records.each_with_index do |file_record, index|
        filepath = file_record.filepath
        expected_hash_value = file_record.checksum
        actual_hash_value = nil
        error = nil

        begin
          actual_hash_value = digest.hexfinal(filepath)
        rescue e
          error = e
        ensure
          digest.reset
        end

        # Get the screen width is time consuming
        {% if flag?(:term_screen) %}
          now = Time.utc
          if index % 100 == 0
            @screen_width = Term::Screen.width.to_i
            last_update_col_time = now
          elsif now - last_update_col_time > Time::Span.new(seconds: 10)
            @screen_width = Term::Screen.width.to_i
            last_update_col_time = now
          end
        {% end %}
        update_count_and_print(index, filepath, expected_hash_value, actual_hash_value, error)
      end

      {
        total:    @n_total,
        success:  @n_success,
        mismatch: @n_mismatch,
        error:    @n_error,
      }
    end

    def update_count_and_print(index, filepath, expected_hash_value, actual_hash_value, error)
      filepath = resolve_filepath(filepath)
      total = @n_total

      # Store the current position of the cursor
      print "\e7" if option.clear_line?

      if error
        print_error_message(filepath, index, total, error)
        @exit_code = EXIT_FAILURE
        @n_error += 1
      elsif expected_hash_value == actual_hash_value
        print_ok_message(filepath, index, total)
        @n_success += 1
      else
        print_mismatch_message(filepath, index, total, expected_hash_value, actual_hash_value)
        @exit_code = EXIT_FAILURE
        @n_mismatch += 1
      end

      # Flush the output
      STDOUT.flush
    end

    def print_ok_message(filepath, index, total)
      print_clear_the_line
      formatted_number = format_file_number(index, total)
      print formatted_number
      print "OK".colorize(:green)
      print ":"

      # Use tab size of 8
      tab_size = 8
      padding_spaces = [tab_size - (formatted_number.size + 3) % tab_size, 0].max
      print " " * padding_spaces

      available_space = @screen_width - formatted_number.size - 3 - padding_spaces
      filepath = filepath.to_s

      if filepath.size > available_space
        print "...#{filepath[-(available_space - 3)..-1]}"
      else
        print filepath
      end
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

      if option.verbose?
        puts " expected: #{expected_hash_value}".colorize(:dark_gray)
        puts " actual:   #{actual_hash_value}".colorize(:dark_gray)
      end
      # store the current position of the cursor
      print "\e7" if option.clear_line?
    end

    def print_error_message(filepath, index, total, error)
      print_clear_the_line
      print format_file_number(index, total)
      print "#{error.class}".colorize(:magenta)
      print ":\t"
      puts filepath
      if option.verbose?
        puts " #{error.message}".colorize(:dark_gray)
      end
      # store the current position of the cursor
      print "\e7" if option.clear_line?
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
    end

    def print_help
      puts parser.help_message
    end

    private def resolve_filepath(filename)
      return "-" if filename == "-"
      option.absolute_path? ? File.expand_path(filename) : filename
    end

    private def format_file_number(index, total)
      total_digits = total.to_s.size
      formatted_index = (index + 1).to_s.rjust(total_digits, ' ')
      "(#{formatted_index}/#{total}) "
    end

    private def print_clear_the_line
      if option.clear_line?
        # restore the cursor to the last saved position
        print "\e8"
        # erase from cursor until end of screen
        print "\e[J"
        # Carriage return
        print "\r"
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
