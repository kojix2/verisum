require "spec"
require "../src/verisum/app"

describe Verisum::App do
  describe "Exit code for normal termination" do
    it "defines EXIT_SUCCESS as 0" do
      Verisum::App::EXIT_SUCCESS.should eq 0
    end

    it "sets exit code to 0 when all checksums are verified successfully" do
      app = Verisum::App.new
      app.stdout = IO::Memory.new
      e = app.run(["spec/fixtures/md5_correct"])
      e.should eq 0
    end
  end

  describe "Exit code for abnormal termination" do
    it "defines EXIT_FAILURE as 1" do
      Verisum::App::EXIT_FAILURE.should eq 1
    end

    it "sets exit coce to 1 when there is a checksum mismatch or an error" do
      app = Verisum::App.new
      app.stdout = IO::Memory.new
      e = app.run(["spec/fixtures/md5"])
      e.should eq 1
    end
  end
end
