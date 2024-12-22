require "./spec_helper"

describe CheckSum::FileRecord do
  it "can be created with a checksum and file path" do
    record = CheckSum::FileRecord.new("checksumchecksum", Path["/path/to/file"])
    record.checksum.should eq "checksumchecksum"
    record.filepath.should eq Path["/path/to/file"]
  end

  it "can be converted to a string" do
    record = CheckSum::FileRecord.new("checksumchecksum", Path["/path/to/file"])
    record.to_s.should eq "checksumchecksum  /path/to/file"
  end

  it "can guess the algorithm md5 based on the checksum length" do
    record = CheckSum::FileRecord.new("d41d8cd98f00b204e9800998ecf8427e", Path["/path/to/file"])
    record.guess_algorithm.should eq CheckSum::Algorithm::MD5
  end

  it "can guess the algorithm sha1 based on the checksum length" do
    record = CheckSum::FileRecord.new("da39a3ee5e6b4b0d3255bfef95601890afd80709", Path["/path/to/file"])
    record.guess_algorithm.should eq CheckSum::Algorithm::SHA1
  end

  it "can guess the algorithm sha256 based on the checksum length" do
    record = CheckSum::FileRecord.new("e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855", Path["/path/to/file"])
    record.guess_algorithm.should eq CheckSum::Algorithm::SHA256
  end

  it "can guess the algorithm sha512 based on the checksum length" do
    record = CheckSum::FileRecord.new("cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e", Path["/path/to/file"])
    record.guess_algorithm.should eq CheckSum::Algorithm::SHA512
  end

  it "raises an error if the checksum length is unknown" do
    expect_raises CheckSum::UnknownAlgorithmError do
      CheckSum::FileRecord.new("unknownchecksum", Path["/path/to/file"]).guess_algorithm
    end
  end
end
