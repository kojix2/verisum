require "../redirect"
require "./utils"

module CheckSum
  class App
    class Computer
      include Redirect
      include Utils

      getter option : Option
      getter exit_code : Int32

      def initialize(@option : Option, @stdout : IO = STDOUT, @stderr : IO = STDERR)
        @exit_code = EXIT_SUCCESS
      end

      def run : Int32
        elapsed_time = process_files
        print_summary(elapsed_time) if option.verbose?
        @exit_code
      end

      private def process_files
        Time.measure do
          option.filenames.each do |filename|
            calculate_file_checksum(filename)
          end
        end
      end

      private def print_summary(elapsed_time)
        stderr.puts "[checksum] (#{format_time_span(elapsed_time)})".colorize(:dark_gray)
      end

      def calculate_file_checksum(filename : String)
        filename = resolve_filepath(filename)
        check_file_validity(filename)
        algorithm = option.algorithm
        if algorithm
          record = calculate_checksum(filename, algorithm)
          puts record.to_s
        else
          raise NoAlgorithmError.new
        end
      end

      private def check_file_validity(filename : String)
        return if filename == "-" # stdin

        unless File.exists?(filename)
          raise FileNotFoundError.new(filename)
        end

        case File.info(filename).type
        when File::Type::Directory
          raise IsADirectoryError.new(filename)
        when File::Type::Symlink
          stderr.puts "#{filename} is a symbolic link"
        end
      end
    end
  end
end
