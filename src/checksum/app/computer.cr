require "../redirect"
require "./utils"

module CheckSum
  class App
    class Computer
      include Redirect
      include Utils

      getter option : Option
      getter exit_code : Int32

      def self.run(option : Option, stdout : IO, stderr : IO) : Int32
        new(option, stdout, stderr).run
      end

      def initialize(@option : Option, @stdout : IO = STDOUT, @stderr : IO = STDERR)
        @exit_code = EXIT_SUCCESS
      end

      def run : Int32
        elapsed_time = process_files
        print_summary(elapsed_time) if option.verbose?
        @exit_code
      end

      private def process_files : Time::Span
        Time.measure do
          option.filenames.each do |filename|
            puts calculate_file_checksum(filename)
          end
        end
      end

      private def print_summary(elapsed_time) : Nil
        stderr.puts "[checksum] (#{format_time_span(elapsed_time)})".colorize(:dark_gray)
      end

      def calculate_file_checksum(filename : String) : FileRecord
        filename = resolve_filepath(filename)
        check_file_validity(filename)

        algorithm = select_algorithm
        calculate_checksum(filename, algorithm)
      end

      def calculate_checksum(filename : String, algorithm : Algorithm) : FileRecord
        d = Digest.new(algorithm)
        s = d.hexfinal(filename == "-" ? STDIN : filename)
        FileRecord.new(s, Path[filename])
      end

      private def select_algorithm : Algorithm
        option.algorithm || raise NoAlgorithmError.new
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
