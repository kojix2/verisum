module CheckSum
  enum Action
    Compute
    Check
    Version
    Help
    None
  end

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

  struct Option
    property action : Action = Action::Check
    property algorithm : Algorithm? = nil
    property filenames : Array(String) = [] of String
    property? clear_line : Bool = true
    property? verbose : Bool = false
    property? absolute_path : Bool = false
  end
end
