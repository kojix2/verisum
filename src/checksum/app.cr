require "colorize"
{% if flag?(:term_screen) %}
  require "term-screen"
{% end %}

require "./parser"
require "./option"
require "./file_record"
require "./digest"

require "./app/*"

module CheckSum
  class App
    getter parser : Parser
    getter option : Option

    property output : IO = STDOUT
    getter exit_code : Int32

    EXIT_SUCCESS = 0
    EXIT_FAILURE = 1

    @screen_width : Int32

    # Override the default output stream
    private def print(*args)
      output.print(*args)
    end

    # Override the default output stream
    private def puts(*args)
      output.puts(*args)
    end

    def initialize(@output : IO = STDOUT)
      @option = Option.new
      @parser = Parser.new(@option)

      @n_total = 0
      @n_success = 0
      @n_mismatch = 0
      @n_error = 0

      @screen_width = \
         begin
          ENV.fetch("COLUMNS", 80).to_i
        rescue
          80
        end

      # Term::Screen.width.to_i # tput cols

      @exit_code = EXIT_SUCCESS
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
      STDERR.puts "[checksum] ERROR: #{ex.class} #{ex.message}".colorize(:red).bold
      STDERR.puts "\n#{ex.backtrace.join("\n")}" if CheckSumError.debug?
      exit(1)
    end
  end
end
