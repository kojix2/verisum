module CheckSum
  class App
    private def resolve_filepath(filename)
      if filename == "-"
        if File.exists?("-")
          stderr.puts "[checksum] File “-” exists. Read #{File.expand_path(filename)} instead of standard input"
        else # stdin
          return "-"
        end
      end
      option.absolute_path? ? File.expand_path(filename) : filename
    end

    def calculate_checksum(filename : String, algorithm : Algorithm) : FileRecord
      d = Digest.new(algorithm)
      s = d.hexfinal(filename == "-" ? STDIN : filename)
      d.reset
      FileRecord.new(s, Path[filename])
    end
  end
end
