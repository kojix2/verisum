require "./exception"

module Verisum
  enum Algorithm
    MD5
    SHA1
    SHA256
    SHA512

    def self.valid_hex_length?(size : Int) : Bool
      values.any? { |algorithm| algorithm.hex_length == size }
    end

    def self.from_checksum(checksum : String) : self
      normalized = checksum.downcase

      values.find do |algorithm|
        normalized.size == algorithm.hex_length
      end || raise UnknownAlgorithmError.new("Unknown algorithm for checksum: #{checksum}")
    end

    def hex_length : Int32
      case self
      when MD5    then 32
      when SHA1   then 40
      when SHA256 then 64
      when SHA512 then 128
      else
        raise UnknownAlgorithmError.new("Unknown algorithm: #{self}")
      end
    end

    def create_digest
      case self
      when MD5    then ::Digest::MD5.new
      when SHA1   then ::Digest::SHA1.new
      when SHA256 then ::Digest::SHA256.new
      when SHA512 then ::Digest::SHA512.new
      else # This should never happen
        raise UnknownAlgorithmError.new("Unknown algorithm: #{self}")
      end
    end
  end
end
