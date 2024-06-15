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
  end

  struct Option
    property action : Action = Action::None
    property algorithm : Algorithm = Algorithm::MD5
    property filename : String = ""
    property verbose : Bool = false
  end
end
