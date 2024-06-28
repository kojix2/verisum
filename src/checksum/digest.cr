require "digest/md5"
require "digest/sha1"
require "digest/sha256"
require "digest/sha512"

require "./option"

module CheckSum
  class Digest
    @digest : (::Digest::MD5 | ::Digest::SHA1 | ::Digest::SHA256 | ::Digest::SHA512)

    def self.guess_algorithm(filename : String) : Algorithm
      case File.basename(filename).downcase
      when /sha512/
        Algorithm::SHA512
      when /sha256/
        Algorithm::SHA256
      when /sha1/
        Algorithm::SHA1
      when /md5/
        Algorithm::MD5
      else
        raise CheckSumError.new("Cannot guess the algorithm from the filename: #{filename}")
      end
    end

    getter algorithm : Algorithm

    def initialize(algorithm : Algorithm)
      @algorithm = algorithm
      @digest = create_digest_instance
    end

    def create_digest_instance
      case @algorithm
      when Algorithm::MD5
        ::Digest::MD5.new
      when Algorithm::SHA1
        ::Digest::SHA1.new
      when Algorithm::SHA256
        ::Digest::SHA256.new
      when Algorithm::SHA512
        ::Digest::SHA512.new
      else
        raise CheckSumError.new("Unknown algorithm: #{@algorithm}")
      end
    end

    def hexfinal_file(filename : String | Path) : String
      @digest.file(filename).hexfinal
    end

    def reset
      @digest.reset
    end
  end
end
