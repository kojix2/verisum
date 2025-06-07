module Verisum
  class App
    class FileNames
      include Redirect

      def initialize(option : Option)
        @filenames = option.filenames
        @absolute_path = option.absolute_path?
      end

      def each(&)
        @filenames.each do |filename|
          if stdin_mark?(filename)
            yield "-"
          else
            f = resolve_filepath(filename)
            check_file_validity(f)
            yield f
          end
        end
      end

      private def resolve_filepath(filename)
        if stdin_mark?(filename)
          if File.exists?("-")
            stderr.puts "[verisum] File “-” exists. Read #{File.expand_path(filename)} instead of standard input"
          else # stdin
            return "-"
          end
        end
        @absolute_path ? File.expand_path(filename) : filename
      end

      private def check_file_validity(filename : String, exist = true, directory = true, info_symlink = false)
        return if stdin_mark?(filename)
        ensure_file_exists(filename) if exist
        ensure_not_directory(filename) if directory
        info_if_symlink(filename) if info_symlink
      end

      private def stdin_mark?(filename)
        filename == "-"
      end

      private def ensure_file_exists(filename)
        unless File.exists?(filename)
          raise FileNotFoundError.new(filename)
        end
      end

      private def ensure_not_directory(filename)
        if File.directory?(filename)
          raise IsADirectoryError.new(filename)
        end
      end

      private def info_if_symlink(filename)
        if File.symlink?(filename)
          stderr.puts "#{filename} is a symbolic link"
        end
      end
    end
  end
end
