module CheckSum
  class App
    private def resolve_filepath(filename)
      return "-" if filename == "-"
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
