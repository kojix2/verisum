require "spec"
require "../src/verisum/algorithm"

describe Verisum::Algorithm do
  describe ".valid_hex_length?" do
    it "accepts the registered checksum lengths" do
      Verisum::Algorithm.valid_hex_length?(32).should be_true
      Verisum::Algorithm.valid_hex_length?(40).should be_true
      Verisum::Algorithm.valid_hex_length?(64).should be_true
      Verisum::Algorithm.valid_hex_length?(128).should be_true
    end

    it "rejects unregistered checksum lengths" do
      Verisum::Algorithm.valid_hex_length?(33).should be_false
    end
  end

  describe ".from_checksum" do
    it "detects the algorithm from checksum length" do
      Verisum::Algorithm.from_checksum("d41d8cd98f00b204e9800998ecf8427e").should eq Verisum::Algorithm::MD5
      Verisum::Algorithm.from_checksum("DA39A3EE5E6B4B0D3255BFEF95601890AFD80709").should eq Verisum::Algorithm::SHA1
    end

    it "raises an error for unsupported checksum lengths" do
      expect_raises Verisum::UnknownAlgorithmError do
        Verisum::Algorithm.from_checksum("abc")
      end
    end
  end

  describe "#create_digest" do
    Verisum::Algorithm.each do |algorithm|
      it "returns a digest object for #{algorithm}" do
        algorithm.create_digest.should be_a(::Digest)
      end
    end
  end
end
