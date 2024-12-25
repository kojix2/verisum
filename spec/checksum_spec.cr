require "./spec_helper"

describe CheckSum do
  it "has a version number" do
    CheckSum::VERSION.should be_a String
  end

  it "has a source URL" do
    CheckSum::SOURCE.should be_a String
  end
end
