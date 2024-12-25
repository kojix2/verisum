require "./spec_helper"

describe CheckSum::App do
  describe CheckSum::Action::Version do
    it "outputs the application version" do
      app = CheckSum::App.new
      app.stdout = IO::Memory.new
      app.print_version
      app.stdout.to_s.should eq "checksum #{CheckSum::VERSION}\n"
    end
  end

  describe CheckSum::Action::Help do
    it "displays the help message" do
      app = CheckSum::App.new
      app.stdout = IO::Memory.new
      app.print_help
      app.stdout.to_s.should match /Usage: checksum \[options\] \[files ...\]/
    end
  end

  describe "Exit code for normal termination" do
    it "defines EXIT_SUCCESS as 0" do
      CheckSum::App::EXIT_SUCCESS.should eq 0
    end

    it "defaults to an exit code of 0" do
      app = CheckSum::App.new
      app.exit_code.should eq CheckSum::App::EXIT_SUCCESS
    end

    it "sets exit code to 0 when all checksums are verified successfully" do
      app = CheckSum::App.new
      app.stdout = IO::Memory.new
      records = app.parse_checksum_file("spec/fixtures/md5_correct")
      Dir.cd Path[__DIR__] / "fixtures" do
        result = app.verify_checksums(records, CheckSum::Algorithm::MD5)
        result.to_h.should eq({total: 4, success: 4, mismatch: 0, error: 0})
        app.exit_code.should eq CheckSum::App::EXIT_SUCCESS
      end
    end
  end

  describe "Exit code for abnormal termination" do
    it "defines EXIT_FAILURE as 1" do
      CheckSum::App::EXIT_FAILURE.should eq 1
    end

    it "sets exit coce to 1 when there is a checksum mismatch or an error" do
      app = CheckSum::App.new
      app.stdout = IO::Memory.new
      records = app.parse_checksum_file("spec/fixtures/md5")
      Dir.cd Path[__DIR__] / "fixtures" do
        result = app.verify_checksums(records, CheckSum::Algorithm::MD5)
        result.to_h.should eq({total: 5, success: 3, mismatch: 1, error: 1})
        app.exit_code.should eq 1
      end
    end
  end
end
