require "./action"
require "./algorithm"

module CheckSum
  struct Option
    property action : Action = Action::Check
    property algorithm : Algorithm? = nil
    property filenames : Array(String) = [] of String
    property? clear_line : Bool = true
    property? verbose : Bool = false
    property? absolute_path : Bool = false
  end
end
