module CheckSum
  class App
    def print_version(io : IO)
      io << "checksum " << VERSION << "\n"
    end
  end
end
