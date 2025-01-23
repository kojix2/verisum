require "spec"
require "../../src/verisum/app/version"

describe Verisum::App do
  describe Verisum::Action::Version do
    it "outputs the application version" do
      app = Verisum::App.new
      io = IO::Memory.new
      app.print_version io
      io.to_s.should eq "verisum #{Verisum::VERSION}\n"
    end
  end
end
