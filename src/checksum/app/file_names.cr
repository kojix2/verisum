module CheckSum
  class App
    class FileNames
      include Redirect

      def initialize(option : Option, @stdout : IO = STDOUT, @stderr : IO = STDERR)
        @filenames = option.filenames
        @absolute_path = option.absolute_path?
      end

      def each
        @filenames.each do |filename|
          if filename == "-"
            yield "-"
          else
            f = resolve_filepath(filename)
            check_file_validity(f)
            yield f
          end
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

      private def resolve_filepath(filename)
        if filename == "-"
          if File.exists?("-")
            stderr.puts "[checksum] File “-” exists. Read #{File.expand_path(filename)} instead of standard input"
          else # stdin
            return "-"
          end
        end
        @absolute_path ? File.expand_path(filename) : filename
      end
    end
  end
end
