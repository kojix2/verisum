module CheckSum
  class App
    def run_check
      option.filenames.each do |filename|
        run_check_file(filename)
      end
    end

    def run_check_file(filename : String)
      filename = resolve_filepath(filename)
      records = parse_checksum_file(filename)
      return if records.empty?

      algorithm =
        if option.algorithm == Algorithm::AUTO
          records.first.guess_algorithm
        else
          option.algorithm
        end

      puts "#{records.size} files in #{(filename == "-" ? "standard input" : filename).colorize.bold}"

      if option.verbose?
        puts "[checksum] Guessed algorithm: #{algorithm}".colorize(:dark_gray)
      end

      results = nil
      elapsed_time = Time.measure do
        Dir.cd(File.dirname(filename)) do
          results = verify_file_checksums(records, algorithm)
        end
      end

      print_result(results, elapsed_time) unless results.nil?
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
        parse_line(line)
      end.to_a.compact
    end

    private def parse_line(line : String) : FileRecord?
      return nil if line =~ /^\s*#/ # Skip comment lines
      sum, path = line.chomp.split
      FileRecord.new(sum, Path[path])
    rescue
      raise ParseError.new(line)
    end

    # Verify the MD5 checksums of the files
    def verify_file_checksums(records : Array(FileRecord), algorithm : Algorithm)
      result = CheckResult.new(total: records.size.to_u64)

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

        update_count_and_print(result, filepath, index, expected_hash_value, actual_hash_value, error)
      end

      result
    end

    def update_count_and_print(result, filepath, index, expected_hash_value, actual_hash_value, error)
      filepath = resolve_filepath(filepath)
      total = result.total

      if error
        print_error_message(filepath, index, total, error)
        @exit_code = EXIT_FAILURE
        @clear_flag = false
        result.error += 1
      elsif expected_hash_value == actual_hash_value
        print_ok_message(filepath, index, total)
        @clear_flag = true
        result.success += 1
      else
        print_mismatch_message(filepath, index, total, expected_hash_value, actual_hash_value)
        @exit_code = EXIT_FAILURE
        @clear_flag = false
        result.mismatch += 1
      end

      # Flush the output
      stdout.flush
      result
    end

    private def print_clear_line : Bool
      if option.clear_line? && @clear_flag
        # restore the cursor to the last saved position
        print "\e8"
        # erase from cursor until end of screen
        print "\e[J"
        # Carriage return
        print "\r"
        true
      else
        false
      end
    end

    def print_ok_message(filepath, index, total) : Nil
      print_clear_line

      print "\e7" if option.clear_line?
      formatted_number = format_file_number(index, total)
      print formatted_number
      print "OK".colorize(:green)
      print ":"

      # Use tab size of 8
      tab_size = 8
      padding_spaces = [tab_size - (formatted_number.size + 3) % tab_size, 0].max
      print " " * padding_spaces

      available_space = screen_width - formatted_number.size - 3 - padding_spaces
      filepath = filepath.to_s

      if filepath.size > available_space
        print "...#{filepath[-(available_space - 3)..-1]}"
      else
        print filepath
      end

      puts unless option.clear_line?
    end

    def print_mismatch_message(filepath, index, total, expected_hash_value, actual_hash_value) : Nil
      print_clear_line

      print format_file_number(index, total)
      print "Mismatch Error".colorize(:red)
      print ":\t"
      print filepath

      # Check if the file is very small or empty
      if File.size(filepath) < 100
        print "\t"
        puts "(#{File.size(filepath)} bytes)".colorize(:dark_gray)
      end

      if option.verbose?
        puts " expected: #{expected_hash_value}".colorize(:dark_gray)
        puts " actual:   #{actual_hash_value}".colorize(:dark_gray)
      end
    end

    def print_error_message(filepath, index, total, error) : Nil
      print_clear_line

      print format_file_number(index, total)
      if error.class == File::NotFoundError
        error_name = "NotFound Error"
      else
        error_name = error.class
      end
      print "#{error_name}".colorize(:magenta)
      print ":\t"
      puts filepath
      puts " #{error.message}".colorize(:dark_gray) if option.verbose?
    end

    def print_result(result, elapsed_time) : Nil
      print_clear_line

      # Print the result
      print "#{result.total} files, "
      print_status("success", result.success, :green)
      print ", "
      print_status("mismatch", result.mismatch, :red)
      print ", "
      print_status("errors", result.error, :magenta)

      # Print the elapsed time
      puts "  (#{format_time_span(elapsed_time)})"
    end

    private def print_status(label, count, color) : Nil
      if count.zero?
        print "#{count} #{label}"
      else
        print "#{count} #{label}".colorize(color)
      end
    end
  end
end
