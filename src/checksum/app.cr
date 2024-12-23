require "colorize"

require "./parser"
require "./option"
require "./file_record"
require "./digest"
require "./redirect"

require "./app/*"

module CheckSum
  class App
    include Redirect

    getter parser : Parser
    getter option : Option

    getter exit_code : Int32

    EXIT_SUCCESS = 0
    EXIT_FAILURE = 1

    def initialize
      @option = Option.new
      @parser = Parser.new(@option)

      @exit_code = EXIT_SUCCESS
    end

    def screen_width : Int32
      begin
        ENV.fetch("COLUMNS", 80).to_i
      rescue
        80
      end
    end

    def run
      @option = parser.parse(ARGV)
      case option.action
      when Action::Calculate
        run_calculate
      when Action::Check
        run_check
      when Action::Version
        print_version
      when Action::Help
        print_help
      else
        print_help
      end
      exit(@exit_code)
    rescue ex
      stderr.puts "[checksum] ERROR: #{ex.class} #{ex.message}".colorize(:red).bold
      stderr.puts "\n#{ex.backtrace.join("\n")}" if CheckSumError.debug?
      exit(1)
    end
  end
end
