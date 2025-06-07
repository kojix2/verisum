require "../redirect"
require "./file_names"
require "./utils"

module Verisum
  class App
    class Computer
      include Redirect
      include Utils

      getter option : Option
      getter exit_code : Int32

      def self.run(option : Option, stdout : IO, stderr : IO) : Int32
        computer = new(option)
        computer.stdout = stdout
        computer.stderr = stderr
        computer.initialize_filenames
        computer.run
      end

      def initialize(@option : Option)
        @exit_code = EXIT_SUCCESS
        @algorithm = option.algorithm || raise NoAlgorithmError.new
        @filenames = FileNames.new(@option)
      end

      def initialize_filenames
        @filenames.stdout = stdout
        @filenames.stderr = stderr
      end

      def run : Int32
        if option.verbose?
          print_time Time.measure { process_files }
        else
          process_files
        end

        @exit_code
      end

      private def process_files : Nil
        @filenames.each do |filename|
          puts calculate_checksum(filename)
        end
      end

      private def calculate_checksum(filename : String) : FileRecord
        d = Digest.new(@algorithm)
        s = d.hexfinal(filename == "-" ? STDIN : filename)
        FileRecord.new(s, Path[filename])
      end

      private def print_time(elapsed_time) : Nil
        stderr.puts "[verisum] (#{format_time_span(elapsed_time)})".colorize(:dark_gray)
      end
    end
  end
end
