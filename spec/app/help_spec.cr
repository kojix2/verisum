require "spec"
require "../../src/verisum/app/help"

describe Verisum::App do
  it "displays the help message" do
    app = Verisum::App.new
    io = IO::Memory.new
    app.print_help io
    io.to_s.should match /Usage: verisum \[options\] \[files ...\]/
  end
end
