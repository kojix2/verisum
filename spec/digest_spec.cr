require "./spec_helper"

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
    expected_checksum = "d41d8cd98f00b204e9800998ecf8427e"
    File.tempfile("checksum_test", "md5") do |temp_file|
      temp_file.print("Test data for checksumming")
      digest = CheckSum::Digest.new(CheckSum::Algorithm::MD5)
      digest.hexfinal(temp_file.path).should eq expected_checksum

      digest.reset
      digest = CheckSum::Digest.new(CheckSum::Algorithm::MD5)
      digest.hexfinal(temp_file.path).should eq expected_checksum
    end
  end

  it "computes the correct SHA1 checksum of a file" do
    expected_checksum = "da39a3ee5e6b4b0d3255bfef95601890afd80709"
    File.tempfile("checksum_test", "sha1") do |temp_file|
      temp_file.print("Test data for checksumming")
      digest = CheckSum::Digest.new(CheckSum::Algorithm::SHA1)
      digest.hexfinal(temp_file.path).should eq expected_checksum

      digest.reset
      digest = CheckSum::Digest.new(CheckSum::Algorithm::SHA1)
      digest.hexfinal(temp_file.path).should eq expected_checksum
    end
  end

  it "computes the correct SHA256 checksum of a file" do
    expected_checksum = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    File.tempfile("checksum_test", "sha256") do |temp_file|
      temp_file.print("Test data for checksumming")
      digest = CheckSum::Digest.new(CheckSum::Algorithm::SHA256)
      digest.hexfinal(temp_file.path).should eq expected_checksum

      digest.reset
      digest = CheckSum::Digest.new(CheckSum::Algorithm::SHA256)
      digest.hexfinal(temp_file.path).should eq expected_checksum
    end
  end

  it "computes the correct SHA512 checksum of a file" do
    expected_checksum = "cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e"
    File.tempfile("checksum_test", "sha512") do |temp_file|
      temp_file.print("Test data for checksumming")
      digest = CheckSum::Digest.new(CheckSum::Algorithm::SHA512)
      digest.hexfinal(temp_file.path).should eq expected_checksum

      digest.reset
      digest = CheckSum::Digest.new(CheckSum::Algorithm::SHA512)
      digest.hexfinal(temp_file.path).should eq expected_checksum
    end
  end
end
