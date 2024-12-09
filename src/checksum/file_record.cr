module CheckSum
  # Define a FileRecord structure to store the checksum and file path
  struct FileRecord
    property checksum : String
    property filepath : Path

    def initialize(@checksum, @filepath)
    end

    def to_s
      return checksum if filepath == Path["-"]
      "#{checksum}  #{filepath}"
    end
  end
end
