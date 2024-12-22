module CheckSum
  module Redirect
    property stdout : IO = STDOUT
    property stderr : IO = STDERR

    # Override the default output stream
    private def print(*args)
      stdout.print(*args)
    end

    # Override the default output stream
    private def puts(*args)
      stdout.puts(*args)
    end
  end
end
