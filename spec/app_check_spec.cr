require "./spec_helper"

NUM_FILES       = 5
EXPECTED_RESULT = CheckSum::App::CheckResult.new(total: 5, success: 3, mismatch: 1, error: 1)

describe CheckSum::App do
  describe "#parse_checksum_file" do
    it "can parse a md5 checksum file" do
      checker = CheckSum::App::Checker.new
      records = checker.parse_checksum_file("spec/fixtures/md5")
      records.should be_a Array(CheckSum::FileRecord)
      records.size.should eq NUM_FILES
    end

    it "can parse a sha1 checksum file" do
      checker = CheckSum::App::Checker.new
      records = checker.parse_checksum_file("spec/fixtures/sha1")
      records.should be_a Array(CheckSum::FileRecord)
      records.size.should eq NUM_FILES
    end

    it "can parse a sha256 checksum file" do
      checker = CheckSum::App::Checker.new
      records = checker.parse_checksum_file("spec/fixtures/sha256")
      records.should be_a Array(CheckSum::FileRecord)
      records.size.should eq NUM_FILES
    end

    it "can parse a sha512 checksum file" do
      checker = CheckSum::App::Checker.new
      records = checker.parse_checksum_file("spec/fixtures/sha512")
      records.should be_a Array(CheckSum::FileRecord)
      records.size.should eq NUM_FILES
    end

    it "can parse a file with a BOM + record" do
      checker = CheckSum::App::Checker.new
      records = checker.parse_checksum_file("spec/fixtures/md5_bom1")
      records.should be_a Array(CheckSum::FileRecord)
      records.size.should eq NUM_FILES
    end

    it "can parse a file with a BOM + comment" do
      checker = CheckSum::App::Checker.new
      records = checker.parse_checksum_file("spec/fixtures/md5_bom2")
      records.should be_a Array(CheckSum::FileRecord)
      records.size.should eq NUM_FILES
    end

    it "raises an error when the file corrupt" do
      checker = CheckSum::App::Checker.new
      checker.stderr = IO::Memory.new
      expect_raises CheckSum::ParseError do
        checker.parse_checksum_file("spec/fixtures/fox.txt")
      end
      expect_raises CheckSum::ParseError do
        checker.parse_checksum_file("spec/fixtures/lorem.txt")
      end
    end
  end

  describe "#verify_checksums" do
    it "can verify md5 checksums" do
      checker = CheckSum::App::Checker.new
      checker.stdout = IO::Memory.new
      records = checker.parse_checksum_file("spec/fixtures/md5")
      Dir.cd Path[__DIR__] / "fixtures" do
        result = checker.verify_checksums(records, CheckSum::Algorithm::MD5)
        result.should eq EXPECTED_RESULT
        checker.exit_code.should eq 1
      end
    end

    it "can verify sha1 checksums" do
      checker = CheckSum::App::Checker.new
      checker.stdout = IO::Memory.new
      records = checker.parse_checksum_file("spec/fixtures/sha1")
      Dir.cd Path[__DIR__] / "fixtures" do
        result = checker.verify_checksums(records, CheckSum::Algorithm::SHA1)
        result.should eq EXPECTED_RESULT
        checker.exit_code.should eq 1
      end
    end

    it "can verify sha256 checksums" do
      checker = CheckSum::App::Checker.new
      checker.stdout = IO::Memory.new
      records = checker.parse_checksum_file("spec/fixtures/sha256")
      Dir.cd Path[__DIR__] / "fixtures" do
        result = checker.verify_checksums(records, CheckSum::Algorithm::SHA256)
        result.should eq EXPECTED_RESULT
        checker.exit_code.should eq 1
      end
    end

    it "can verify sha512 checksums" do
      checker = CheckSum::App::Checker.new
      checker.stdout = IO::Memory.new
      records = checker.parse_checksum_file("spec/fixtures/sha512")
      Dir.cd Path[__DIR__] / "fixtures" do
        result = checker.verify_checksums(records, CheckSum::Algorithm::SHA512)
        result.should eq EXPECTED_RESULT
        checker.exit_code.should eq 1
      end
    end
  end

  describe "#print methods" do
    it "prints OK message correctly" do
      checker = CheckSum::App::Checker.new
      checker.stdout = IO::Memory.new
      checker.print_ok_message("/short/path", 0, NUM_FILES)
      output = checker.stdout.to_s
      output.should contain "OK".colorize(:green).to_s
      output.should contain "(1/#{NUM_FILES})"
      output.should contain "/short/path"
    end

    it "prints truncated long file paths in OK message" do
      checker = CheckSum::App::Checker.new
      checker.stdout = IO::Memory.new
      checker.screen_width = 25
      long_path = "/a/very/long/path/that/needs/truncation"
      checker.print_ok_message(long_path, 0, NUM_FILES)
      output = checker.stdout.to_s
      output.should contain "...cation"
      output.should_not contain "/a/very/long/path"
    end

    it "prints mismatch message with details when verbose is enabled" do
      checker = CheckSum::App::Checker.new
      checker.stdout = IO::Memory.new
      checker.option.verbose = true
      checker.print_mismatch_message(__FILE__, 1, NUM_FILES, "expected_hash", "actual_hash")
      output = checker.stdout.to_s
      output.should contain "Mismatch".colorize(:red).to_s
      output.should contain "expected: expected_hash"
      output.should contain "actual:   actual_hash"
    end

    it "prints error message for file not found" do
      checker = CheckSum::App::Checker.new
      checker.stdout = IO::Memory.new
      error = File::NotFoundError.new("File not found", file: "/missing/file")
      checker.print_error_message("/missing/file", 2, NUM_FILES, error)
      output = checker.stdout.to_s
      output.should contain "NotFound".colorize(:magenta).to_s
      output.should contain "/missing/file"
    end

    it "prints result summary correctly" do
      checker = CheckSum::App::Checker.new
      checker.stdout = IO::Memory.new
      result = CheckSum::App::CheckResult.new(total: 5, success: 4, mismatch: 1, error: 0)
      elapsed_time = Time::Span.new(nanoseconds: 1234567890)
      checker.print_result(result, elapsed_time)
      output = checker.stdout.to_s
      output.should contain "4 successes".colorize(:green).to_s
      output.should contain "1 mismatch".colorize(:red).to_s
      output.should_not contain "1 mismatches".colorize(:red).to_s
      output.should contain "0 errors"
      output.should contain "(1.23 seconds)"
    end
  end
end
