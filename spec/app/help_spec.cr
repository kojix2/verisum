require "spec"
require "../../src/checksum/app/help"

describe CheckSum::App do
  it "displays the help message" do
    app = CheckSum::App.new
    io = IO::Memory.new
    app.print_help io
    io.to_s.should match /Usage: checksum \[options\] \[files ...\]/
  end
end
