require "spec"
require "../src/verisum/version"

describe Verisum do
  it "has a VERSION constant" do
    Verisum::VERSION.should match(/\d+\.\d+\.\d+/)
  end

  it "has a SOURCE constant" do
    Verisum::SOURCE.should match(/^https:\/\/.*\/verisum/)
  end
end
