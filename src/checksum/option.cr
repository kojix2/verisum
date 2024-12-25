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
  end

  struct Option
    property action : Action = Action::Compute
    property algorithm : Algorithm? = nil
    property filenames : Array(String) = [] of String
    property? clear_line : Bool = true
    property? verbose : Bool = false
    property? absolute_path : Bool = false
  end
end
