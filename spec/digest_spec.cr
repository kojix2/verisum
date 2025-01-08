require "spec"
require "../src/checksum/digest"

describe CheckSum::Digest do
  it "creates an MD5 digest instance" do
    digest = CheckSum::Digest.new(CheckSum::Algorithm::MD5)
    digest.inspect.should match(/Digest::MD5/)
    digest.algorithm.should eq CheckSum::Algorithm::MD5
  end

  it "creates a SHA1 digest instance" do
    digest = CheckSum::Digest.new(CheckSum::Algorithm::SHA1)
    digest.inspect.should match(/Digest::SHA1/)
    digest.algorithm.should eq CheckSum::Algorithm::SHA1
  end

  it "creates a SHA256 digest instance" do
    digest = CheckSum::Digest.new(CheckSum::Algorithm::SHA256)
    digest.inspect.should match(/Digest::SHA256/)
    digest.algorithm.should eq CheckSum::Algorithm::SHA256
  end

  it "creates a SHA512 digest instance" do
    digest = CheckSum::Digest.new(CheckSum::Algorithm::SHA512)
    digest.inspect.should match(/Digest::SHA512/)
    digest.algorithm.should eq CheckSum::Algorithm::SHA512
  end

  it "computes the correct MD5 checksum of a file" do
    expected_checksum = "351e24791b33e60193200ebe8c92fb4e"
    temp_file = File.tempfile("checksum_test", "md5") do |file|
      file.print("Test data for checksumming")
    end
    begin
      output = IO::Memory.new
      status = Process.run("md5sum", {temp_file.path}, output: output)
      if status.success?
        output.to_s.should contain(expected_checksum)
      end
    rescue File::NotFoundError
      # md5sum is not available
    end
    digest = CheckSum::Digest.new(CheckSum::Algorithm::MD5)
    digest.hexfinal(temp_file.path).should eq expected_checksum
    # no need to reset the digest
    digest.hexfinal(temp_file.path).should eq expected_checksum
    temp_file.delete
  end

  it "computes the correct MD5 checksum of a string" do
    expected_checksum = "351e24791b33e60193200ebe8c92fb4e"
    io = IO::Memory.new
    io.print("Test data for checksumming")
    io.rewind
    digest = CheckSum::Digest.new(CheckSum::Algorithm::MD5)
    digest.hexfinal(io).should eq expected_checksum
    # no need to reset the digest
    io.rewind
    digest.hexfinal(io).should eq expected_checksum
  end

  it "computes the correct SHA1 checksum of a file" do
    expected_checksum = "28f35c8c618f554f2f045acace29ef9aa045cb5c"
    temp_file = File.tempfile("checksum_test", "sha1") do |file|
      file.print("Test data for checksumming")
    end
    begin
      output = IO::Memory.new
      status = Process.run("sha1sum", {temp_file.path}, output: output)
      if status.success?
        output.to_s.should contain(expected_checksum)
      end
    rescue File::NotFoundError
      # sha1sum is not available
    end
    digest = CheckSum::Digest.new(CheckSum::Algorithm::SHA1)
    digest.hexfinal(temp_file.path).should eq expected_checksum
    # no need to reset the digest
    digest.hexfinal(temp_file.path).should eq expected_checksum
    temp_file.delete
  end

  it "computes the correct SHA1 checksum of a string" do
    expected_checksum = "28f35c8c618f554f2f045acace29ef9aa045cb5c"
    io = IO::Memory.new
    io.print("Test data for checksumming")
    io.rewind
    digest = CheckSum::Digest.new(CheckSum::Algorithm::SHA1)
    digest.hexfinal(io).should eq expected_checksum
    # no need to reset the digest
    io.rewind
    digest.hexfinal(io).should eq expected_checksum
  end

  it "computes the correct SHA256 checksum of a file" do
    expected_checksum = "8dea90c10a14fc1d845b9cb393eba69f7aeaf898921b9d7b4f782b2328ed369e"
    temp_file = File.tempfile("checksum_test", "sha256") do |file|
      file.print("Test data for checksumming")
    end
    begin
      output = IO::Memory.new
      status = Process.run("sha256sum", {temp_file.path}, output: output)
      if status.success?
        output.to_s.should contain(expected_checksum)
      end
    rescue File::NotFoundError
      # sha256sum is not available
    end
    digest = CheckSum::Digest.new(CheckSum::Algorithm::SHA256)
    digest.hexfinal(temp_file.path).should eq expected_checksum
    # no need to reset the digest
    digest.hexfinal(temp_file.path).should eq expected_checksum
    temp_file.delete
  end

  it "computes the correct SHA256 checksum of a string" do
    expected_checksum = "8dea90c10a14fc1d845b9cb393eba69f7aeaf898921b9d7b4f782b2328ed369e"
    io = IO::Memory.new
    io.print("Test data for checksumming")
    io.rewind
    digest = CheckSum::Digest.new(CheckSum::Algorithm::SHA256)
    digest.hexfinal(io).should eq expected_checksum
    # no need to reset the digest
    io.rewind
    digest.hexfinal(io).should eq expected_checksum
  end

  it "computes the correct SHA512 checksum of a file" do
    expected_checksum = "8caa15bb97f7f3efd3a333b49791a1fff6921736c83a2f083439a56cee0f64278a980eb6ddd62457849525adb4b32a4df539e8264c9b2582940ffe690e80e76a"
    temp_file = File.tempfile("checksum_test", "sha512") do |file|
      file.print("Test data for checksumming")
    end
    begin
      output = IO::Memory.new
      status = Process.run("sha512sum", {temp_file.path}, output: output)
      if status.success?
        output.to_s.should contain(expected_checksum)
      end
    rescue File::NotFoundError
      # sha512sum is not available
    end
    digest = CheckSum::Digest.new(CheckSum::Algorithm::SHA512)
    digest.hexfinal(temp_file.path).should eq expected_checksum
    # no need to reset the digest
    digest.hexfinal(temp_file.path).should eq expected_checksum
    temp_file.delete
  end

  it "computes the correct SHA512 checksum of a string" do
    expected_checksum = "8caa15bb97f7f3efd3a333b49791a1fff6921736c83a2f083439a56cee0f64278a980eb6ddd62457849525adb4b32a4df539e8264c9b2582940ffe690e80e76a"
    io = IO::Memory.new
    io.print("Test data for checksumming")
    io.rewind
    digest = CheckSum::Digest.new(CheckSum::Algorithm::SHA512)
    digest.hexfinal(io).should eq expected_checksum
    # no need to reset the digest
    io.rewind
    digest.hexfinal(io).should eq expected_checksum
  end

  it "raises an error if the file does not exist" do
    expect_raises File::NotFoundError do
      CheckSum::Digest.new(CheckSum::Algorithm::MD5).hexfinal("nonexistentfile")
    end
  end
end
