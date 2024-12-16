module CheckSum
  # Define a FileRecord structure to store the checksum and file path
  struct FileRecord
    property checksum : String
    property filepath : Path

    def initialize(@checksum, @filepath)
    end

    def guess_algorithm : Algorithm
      case checksum
      when /^[0-9a-f]{32}$/  then Algorithm::MD5
      when /^[0-9a-f]{40}$/  then Algorithm::SHA1
      when /^[0-9a-f]{64}$/  then Algorithm::SHA256
      when /^[0-9a-f]{128}$/ then Algorithm::SHA512
      else
        raise CheckSumError.new("Unknown checksum length: #{checksum.size}")
      end
    end

    def to_s
      return checksum if filepath == Path["-"]
      "#{checksum}  #{filepath}"
    end
  end
end
