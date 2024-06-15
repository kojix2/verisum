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
    AUTO
  end

  struct Option
    property action : Action = Action::None
    property algorithm : Algorithm = Algorithm::AUTO
    property filename : String = ""
    property verbose : Bool = false
  end
end
