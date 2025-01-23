require "../app"

module Verisum
  class App
    def print_help(io : IO)
      parser.help_message(io)
      io << "\n"
    end
  end
end
