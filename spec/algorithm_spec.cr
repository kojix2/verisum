require "spec"
require "../src/checksum/algorithm"

describe CheckSum::Algorithm do
  describe "#create_digest" do
    CheckSum::Algorithm.each do |algorithm|
      it "returns a digest object for #{algorithm}" do
        algorithm.create_digest.should be_a(::Digest)
      end
    end
  end
end
