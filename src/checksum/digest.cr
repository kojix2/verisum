require "digest/md5"
require "digest/sha1"
require "digest/sha256"
require "digest/sha512"

require "./option"

module CheckSum
  class Digest
    @digest : (::Digest::MD5 | ::Digest::SHA1 | ::Digest::SHA256 | ::Digest::SHA512)

    getter algorithm : Algorithm

    def initialize(algorithm : Algorithm)
      @algorithm = algorithm
      @digest = create_digest_instance
    end

    def create_digest_instance : (::Digest::MD5 | ::Digest::SHA1 | ::Digest::SHA256 | ::Digest::SHA512)
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
        # This should never happen
        raise UnknownAlgorithmError.new("Unknown algorithm: #{@algorithm}")
      end
    end

    def hexfinal(filename : String | Path) : String
      @digest.file(filename).hexfinal
    end

    def hexfinal(io : IO) : String
      @digest.update(io).hexfinal
    end

    def reset : Nil
      @digest.reset
    end
  end
end
