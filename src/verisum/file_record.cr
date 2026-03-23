require "./algorithm"
require "./exception"

module Verisum
  # Define a FileRecord structure to store the checksum and file path
  struct FileRecord
    getter checksum : String
    getter filepath : Path

    def initialize(@checksum, @filepath)
    end

    # Returns the algorithm used to calculate the checksum based on the checksum pattern
    def guess_algorithm : Algorithm
      Algorithm.from_checksum(checksum)
    end

    # Return the string representation of the FileRecord
    # If the file path is "-", return only the checksum (for standard input)
    def to_s(io) : Nil
      if filepath == Path["-"]
        io << checksum
      else
        io << checksum << "  " << filepath
      end
    end
  end
end
