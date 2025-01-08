require "colorize"

require "./parser"
require "./option"
require "./file_record"
require "./digest"
require "./redirect"

require "./app/*"
require "./ioctl"

module CheckSum
  # The main application class.
  class App
    include Redirect

    getter parser : Parser
    getter option : Option

    def self.run(argv = ARGV) : Int32
      new.run(argv)
    end

    def initialize
      @option = Option.new
      @parser = Parser.new(@option)
    end

    # Runs the checksum application with the given arguments.
    #
    # Returns the exit code.
    def run(argv = ARGV) : Int32
      @option = parser.parse(argv)
      case option.action
      when Action::Compute
        Computer.run(option, stdout, stderr)
      when Action::Check
        Checker.run(option, stdout, stderr)
      when Action::Version
        print_version(stdout); EXIT_SUCCESS
      when Action::Help
        print_help(stdout); EXIT_SUCCESS
      else
        print_help(stderr); EXIT_FAILURE
      end
    rescue ex
      stderr.puts "[checksum] ERROR: #{ex.class} #{ex.message}".colorize(:red).bold
      stderr.puts "\n#{ex.backtrace.join("\n")}" if CheckSumError.debug?
      EXIT_FAILURE
    end
  end
end
