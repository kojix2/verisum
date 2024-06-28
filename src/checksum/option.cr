module CheckSum
  enum Action
    Calculate
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
    property action : Action = Action::Calculate
    property algorithm : Algorithm = Algorithm::AUTO
    property filenames : Array(String) = [] of String
    property clear_line : Bool = true
    property verbose : Bool = false
    property absolute_path : Bool = false
  end
end
