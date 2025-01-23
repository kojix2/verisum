require "spec"
require "../src/verisum"

describe Verisum do
  it "has a version number" do
    Verisum::VERSION.should be_a String
  end

  it "has a source URL" do
    Verisum::SOURCE.should be_a String
  end
end
