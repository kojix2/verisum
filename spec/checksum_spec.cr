require "./spec_helper"

NUM_FILES       = 5
EXPECTED_RESULT = {total: 5, success: 3, mismatch: 1, error: 1}

describe CheckSum do
  it "has a version number" do
    CheckSum::VERSION.should be_a String
  end

  it "prints the version number" do
    app = CheckSum::App.new
    app.output = IO::Memory.new
    app.print_version
    app.output.to_s.should eq "checksum #{CheckSum::VERSION}\n"
  end

  it "prints help" do
    app = CheckSum::App.new
    app.output = IO::Memory.new
    app.print_help
    app.output.to_s.should match /Usage: checksum \[options\] \[files ...\]/
  end

  it "can parse a md5 checksum file" do
    app = CheckSum::App.new
    records = app.parse_checksum_file("spec/fixtures/md5")
    records.should be_a Array(CheckSum::FileRecord)
    records.size.should eq NUM_FILES
  end

  it "can parse a sha1 checksum file" do
    app = CheckSum::App.new
    records = app.parse_checksum_file("spec/fixtures/sha1")
    records.should be_a Array(CheckSum::FileRecord)
    records.size.should eq NUM_FILES
  end

  it "can parse a sha256 checksum file" do
    app = CheckSum::App.new
    records = app.parse_checksum_file("spec/fixtures/sha256")
    records.should be_a Array(CheckSum::FileRecord)
    records.size.should eq NUM_FILES
  end

  it "can parse a sha512 checksum file" do
    app = CheckSum::App.new
    records = app.parse_checksum_file("spec/fixtures/sha512")
    records.should be_a Array(CheckSum::FileRecord)
    records.size.should eq NUM_FILES
  end

  it "can verify md5 checksums" do
    app = CheckSum::App.new
    app.output = IO::Memory.new
    records = app.parse_checksum_file("spec/fixtures/md5")
    Dir.cd Path[__DIR__] / "fixtures" do
      result = app.verify_file_checksums(records, CheckSum::Algorithm::MD5)
      result.should eq EXPECTED_RESULT
      app.exit_code.should eq 1
    end
  end

  it "can verify sha1 checksums" do
    app = CheckSum::App.new
    app.output = IO::Memory.new
    records = app.parse_checksum_file("spec/fixtures/sha1")
    Dir.cd Path[__DIR__] / "fixtures" do
      result = app.verify_file_checksums(records, CheckSum::Algorithm::SHA1)
      result.should eq EXPECTED_RESULT
      app.exit_code.should eq 1
    end
  end

  it "can verify sha256 checksums" do
    app = CheckSum::App.new
    app.output = IO::Memory.new
    records = app.parse_checksum_file("spec/fixtures/sha256")
    Dir.cd Path[__DIR__] / "fixtures" do
      result = app.verify_file_checksums(records, CheckSum::Algorithm::SHA256)
      result.should eq EXPECTED_RESULT
      app.exit_code.should eq 1
    end
  end

  it "can verify sha512 checksums" do
    app = CheckSum::App.new
    app.output = IO::Memory.new
    records = app.parse_checksum_file("spec/fixtures/sha512")
    Dir.cd Path[__DIR__] / "fixtures" do
      result = app.verify_file_checksums(records, CheckSum::Algorithm::SHA512)
      result.should eq EXPECTED_RESULT
      app.exit_code.should eq 1
    end
  end

  it "can return exit code 0 when all checksums are correct" do
    app = CheckSum::App.new
    app.output = IO::Memory.new
    records = app.parse_checksum_file("spec/fixtures/md5_correct")
    Dir.cd Path[__DIR__] / "fixtures" do
      result = app.verify_file_checksums(records, CheckSum::Algorithm::MD5)
      result.should eq({total: 4, success: 4, mismatch: 0, error: 0})
      app.exit_code.should eq 0
    end
  end
end
