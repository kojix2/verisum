module CheckSum
  class CheckSumError < Exception
    class_property debug : Bool = false
  end

  class FileNotFoundError < Exception
    def initialize(filename)
      super("No such file or directory: #{filename}")
    end
  end

  class IsADirectoryError < Exception
    def initialize(filename)
      super("#{filename} is a directory")
    end
  end
end
