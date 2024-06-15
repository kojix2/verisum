module CheckSum
  enum Action
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
    Unknown
  end

  struct Option
    property action : Action = Action::None
    property algorithm : Algorithm = Algorithm::Unknown
    property filename : String = ""
    property verbose : Bool = false
  end
end
