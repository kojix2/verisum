require "../redirect"
require "../option"
require "../file_record"
require "../digest"
require "../ioctl"
require "./exit_code"
require "./check_result"
require "./utils"

module CheckSum
  class App
    class Checker
      include Redirect
      include Utils

      getter option : Option
      getter exit_code : Int32
      setter screen_width : Int32?

      def self.run(option : Option, stdout : IO, stderr : IO) : Int32
        new(option, stdout, stderr).run
      end

      def initialize(@option : Option = Option.new, @stdout : IO = STDOUT, @stderr : IO = STDERR)
        @exit_code = EXIT_SUCCESS
        @clear_flag = false
        @screen_width = nil
      end

      def screen_width
        @screen_width || CheckSum.screen_width
      end

      def run : Int32
        option.filenames.each do |filename|
          run_check_file(filename)
        end
        @exit_code
      end

      def run_check_file(filename : String)
        filename = resolve_filepath(filename)
        records = parse_checksum_file(filename)
        return if records.empty?

        algorithm = option.algorithm || records.first.guess_algorithm

        puts "#{records.size} files in #{(filename == "-" ? "standard input" : filename).colorize.bold}"

        if option.verbose?
          puts "[checksum] Guessed algorithm: #{algorithm}".colorize(:dark_gray)
        end

        results = nil
        elapsed_time = Time.measure do
          Dir.cd(File.dirname(filename)) do
            results = verify_checksums(records, algorithm)
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
        line = remove_bom(line)
        return nil if line =~ /^\s*#/ # Skip comment lines
        match = line.match(/^([0-9a-zA-Z]+)\s+(.*)$/)
        raise ParseError.new(line) unless match
        sum = match[1]
        path = match[2]
        # validate checksum length
        raise ParseError.new(line) if sum.size < 32
        # validate checksum content
        raise ParseError.new(line) unless sum =~ /^[0-9a-zA-Z]+$/
        FileRecord.new(sum, Path[path])
      rescue
        raise ParseError.new(line)
      end

      # Verify the MD5 checksums of the files
      def verify_checksums(records : Array(FileRecord), algorithm : Algorithm) : CheckResult
        result = CheckResult.new(total: records.size.to_u64)

        digest = Digest.new(algorithm)

        records.each_with_index do |file_record, index|
          filepath = file_record.filepath
          expected_hash_value = file_record.checksum
          actual_hash_value = nil
          error = nil

          begin
            actual_hash_value = digest.hexfinal(filepath)
          rescue e
            error = e
          end

          dispatch(result, filepath, index, expected_hash_value, actual_hash_value, error)
        end

        result
      end

      def evaluate_verification(expected_hash_value, actual_hash_value, error) : Symbol
        if error
          :error
        elsif expected_hash_value != actual_hash_value
          :mismatch
        else
          :success
        end
      end

      def update_counts(result : CheckResult, type : Symbol) : CheckResult
        case type
        when :error
          result.error += 1
        when :success
          result.success += 1
        when :mismatch
          result.mismatch += 1
        else
          raise "Unknown type: #{type}"
        end
        result
      end

      def update_status(type : Symbol) : Int32
        case type
        when :error
          @exit_code = EXIT_FAILURE
        when :success
          @exit_code # nothing to do
        when :mismatch
          @exit_code = EXIT_FAILURE
        else
          raise "Unknown type: #{type}"
        end
      end

      def update_clear_flag(type : Symbol) : Bool
        case type
        when :error
          @clear_flag = false
        when :success
          @clear_flag = true
        when :mismatch
          @clear_flag = false
        else
          raise "Unknown type: #{type}"
        end
      end

      def dispatch(result, filepath, index, expected_hash_value, actual_hash_value, error) : CheckResult
        type = evaluate_verification(expected_hash_value, actual_hash_value, error)
        update_counts(result, type)
        update_status(type)

        total = result.total
        filepath = resolve_filepath(filepath)

        case type
        when :error
          print_error_message(filepath, index, total, error.not_nil!)
        when :success
          print_ok_message(filepath, index, total)
        when :mismatch
          print_mismatch_message(filepath, index, total, expected_hash_value, actual_hash_value)
        end

        update_clear_flag(type)

        # Flush the output
        stdout.flush
        result
      end

      private def print_clear_line
        if option.clear_line? && @clear_flag
          # restore the cursor to the last saved position
          print "\e8"
          # erase from cursor until end of screen
          print "\e[J"
          # Carriage return
          print "\r"
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
        # print " " * padding_spaces
        print "\t"

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
        print "Mismatch".colorize(:red)
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
          error_name = "NotFound"
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

        print " "
        if result.mismatch.zero? && result.error.zero?
          print "✅".colorize(:green).bold
        else
          print "❌".colorize(:red).bold
        end
        print "  "

        print result.to_s

        # Print the elapsed time
        puts "  (#{format_time_span(elapsed_time)})"
      end

      private def format_file_number(index, total)
        total_digits = total.to_s.size
        formatted_index = (index + 1).to_s.rjust(total_digits, ' ')
        "(#{formatted_index}/#{total}) "
      end
    end
  end
end
