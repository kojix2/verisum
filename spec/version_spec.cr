require "spec"
require "../src/checksum/version"

describe CheckSum do
  it "has a VERSION constant" do
    CheckSum::VERSION.should match(/\d+\.\d+\.\d+/)
  end

  it "has a SOURCE constant" do
    CheckSum::SOURCE.should match(/^https:\/\/.*\/checksum/)
  end
end
