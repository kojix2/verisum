require "../spec_helper"

describe CheckSum::App do
  describe CheckSum::Action::Version do
    it "outputs the application version" do
      app = CheckSum::App.new
      io = IO::Memory.new
      app.print_version io
      io.to_s.should eq "checksum #{CheckSum::VERSION}\n"
    end
  end
end
