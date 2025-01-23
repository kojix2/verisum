require "spec"
require "../src/verisum/algorithm"

describe Verisum::Algorithm do
  describe "#create_digest" do
    Verisum::Algorithm.each do |algorithm|
      it "returns a digest object for #{algorithm}" do
        algorithm.create_digest.should be_a(::Digest)
      end
    end
  end
end
