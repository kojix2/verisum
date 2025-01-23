require "../app"

module Verisum
  class App
    def print_version(io : IO)
      io << "verisum " << VERSION << "\n"
    end
  end
end
