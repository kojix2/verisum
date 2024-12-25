module CheckSum
  class App
    def run_calculate
      elapsed_time = Time.measure do
        option.filenames.each do |filename|
          calculate_file_checksum(filename)
        end
      end

      if option.verbose?
        stderr.puts "[checksum] (#{format_time_span(elapsed_time)})".colorize(:dark_gray)
      end
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
