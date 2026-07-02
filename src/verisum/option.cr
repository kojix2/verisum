require "./action"
require "./algorithm"

module Verisum
  class Option
    property action : Action = Action::Check
    property algorithm : Algorithm? = nil
    property base_dir : String = "."
    property filenames : Array(String) = [] of String
    property? chdir : Bool = false
    property? clear_line : Bool = true
    property? verbose : Bool = false
    property? absolute_path : Bool = false
  end
end
