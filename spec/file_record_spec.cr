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
end
