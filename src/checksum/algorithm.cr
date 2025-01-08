require "./exception"

module CheckSum
  enum Algorithm
    MD5
    SHA1
    SHA256
    SHA512

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
