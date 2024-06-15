require "digest/md5"
require "digest/sha1"
require "digest/sha256"
require "digest/sha512"
require "colorize"

require "./parser"
require "./option"
require "./file_record"

module CheckSum
  class App
    getter parser : Parser
    getter option : Option

    def initialize
      @parser = Parser.new
      @option = Option.new # Just for avoiding nil error
    end

    def run
      @option = parser.parse(ARGV)
      case option.action
      when Action::Check
        main_run
      when Action::Version
        print_version
      when Action::Help
        print_help
      else
        print_help
      end
    rescue ex
      error_message = "[checksum] ERROR: #{ex.class} #{ex.message}"
      error_message += "\n#{ex.backtrace.join("\n")}" if CheckSumError.debug
      STDERR.puts error_message
      exit(1)
    end

    def main_run
      @start_time = Time.utc
      filename = option.filename
      algorithm = option.algorithm
      Dir.cd File.dirname(filename)
      records = parse_checksum_file(filename)
      verify_checksums(records, algorithm)
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
    end

    # Verify the MD5 checksums of the files
    def verify_checksums(records : Array(FileRecord), algorithm : Algorithm)
      digest = \
         case algorithm
       when Algorithm::MD5
         Digest::MD5.new
       when Algorithm::SHA1
         Digest::SHA1.new
       when Algorithm::SHA256
         Digest::SHA256.new
       when Algorithm::SHA512
         Digest::SHA512.new
       else
         raise CheckSumError.new("Unknown algorithm: #{algorithm}")
       end

      n_success = 0
      n_mismatch = 0
      n_error = 0

      records.each_with_index do |file_record, index|
        begin
          actual_md5 = digest.file(file_record.filepath).hexfinal
        rescue e
          print("\x1b[2K\r") # Clear the line
          print "(#{index + 1}/#{records.size}) "
          print "#{e.class}".colorize(:magenta)
          print ":\t"
          puts file_record.filepath
          puts " #{e.message}"
          n_error += 1
          next
        end
        expected_md5 = file_record.checksum

        if actual_md5 == expected_md5
          print("\x1b[2K\r") # Clear the line
          print "(#{index + 1}/#{records.size}) "
          print "OK".colorize(:green)
          print ":\t"
          print file_record.filepath
          n_success += 1
        else
          print("\x1b[2K\r") # Clear the line
          print "(#{index + 1}/#{records.size}) "
          print "Mismatch Error".colorize(:red)
          print ":\t"
          puts file_record.filepath
          if option.verbose
            puts " expected: #{expected_md5}".colorize(:dark_gray)
            puts " actual:   #{actual_md5}".colorize(:dark_gray)
          end
          n_mismatch += 1
        end

        digest.reset
      end

      print("\x1b[2K\r") # Clear the line
      # Print the result
      print "#{records.size}"
      print " files, "
      print "#{n_success}"
      print " success, "
      print "#{n_mismatch}"
      print " mismatch, "
      print "#{n_error}"
      print " errors"
      puts
    end

    def print_version
      puts "checksum #{VERSION}"
    end

    def print_help
      puts parser.help
    end
  end
end
