require "digest/md5"
require "digest/sha1"
require "digest/sha256"
require "digest/sha512"

require "./option"

module CheckSum
  class Digest
    @digest : (::Digest::MD5 | ::Digest::SHA1 | ::Digest::SHA256 | ::Digest::SHA512)

    getter algorithm : Algorithm

    def initialize(@algorithm : Algorithm)
      @digest = @algorithm.create_digest
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
