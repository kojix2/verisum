module CheckSum
  class App
    def run_calculate
      elapsed_time = Time.measure do
        option.filenames.each do |filename|
          run_calculate(filename)
        end
      end

      if option.verbose?
        stderr.puts "[checksum] (#{format_time_span(elapsed_time)})".colorize(:dark_gray)
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
          stderr.puts "#{filename} is a symbolic link"
          # If the file is a symlink, it should not be calculated ?
          # should this return nil or raise an error?
        end
      end
      record = calculate_checksum(filename, algorithm)
      puts record.to_s
    end
  end
end
