require "option_parser"

# Customizable Indentation in OptionParser Help Messages
# https://github.com/crystal-lang/crystal/issues/14153

class OptionParser
  # Adds a property for summary_width
  property summary_width : Int32 = 33

  private def append_flag(flag, description)
    indent = " " * (summary_width + 4) # Adjust the indent based on summary_width
    description = description.gsub("\n", "\n#{indent}")

    if flag.size >= summary_width
      @flags << "    #{flag}\n#{indent}#{description}"
    else
      @flags << "    #{flag}#{" " * (summary_width - flag.size)}#{description}"
    end
  end
end

require "colorize"

require "./option"
require "./exception"
require "./redirect"

module CheckSum
  class Parser
    include Redirect

    class NoFileSpecifiedError < CheckSumError
      def initialize
        super("No files specified. Please use '-' to specify standard input.")
      end
    end

    def initialize(@option : Option = Option.new)
      @opt = OptionParser.new
      @opt.summary_width = 23
      @opt.banner = <<-BANNER

        Program: checksum
        Version: #{VERSION}
        Source:  #{SOURCE}

        Usage: checksum [options] [files ...]

        Arguments:
          [files...] File(s). Use a dash ('-') to read from standard input.

        Options;
      BANNER

      @opt.on("-c", "--calc", "Compute checksums") do
        @option.action = Action::Compute
      end

      @opt.on("-a", "--algorithm ALGO", "(md5|sha1|sha256|sha512)") do |algorithm|
        @option.algorithm =
          case algorithm.downcase
          when "md5"
            Algorithm::MD5
          when "sha1"
            Algorithm::SHA1
          when "sha256"
            Algorithm::SHA256
          when "sha512"
            Algorithm::SHA512
          else
            raise ArgumentError.new("Unknown algorithm: #{algorithm}")
          end
      end

      @opt.on("-A", "--absolute", "Output absolute path [false]") do
        @option.absolute_path = true
      end

      @opt.on("-v", "--verbose", "Output checksums and errors, etc [false]") do
        @option.verbose = true
      end

      @option.clear_line = false unless STDOUT.tty?
      @opt.on("-N", "--no-clear", "Do not clear the line after output [false]") do
        @option.clear_line = false
      end

      Colorize.on_tty_only! # [auto]
      @opt.on("-C", "--color WHEN", "When to use color (auto|always|never) [auto]") do |when_|
        case when_
        when "auto"
          Colorize.on_tty_only!
        when "always"
          Colorize.enabled = true
        when "never"
          Colorize.enabled = false
        else
          raise ArgumentError.new("Unknown color mode: #{when_}")
        end
      end

      @opt.on("-D", "--debug", "Print a backtrace on error") do
        CheckSumError.debug = true
      end

      @opt.on("-h", "--help", "Show this message") do
        @option.action = Action::Help
      end

      @opt.on("-V", "--version", "Show version") do
        @option.action = Action::Version
      end

      @opt.invalid_option do |flag|
        help_message(stderr)
        stderr << "\n\n"
        raise OptionParser::InvalidOption.new(flag)
      end

      @opt.missing_option do |flag|
        help_message(stderr)
        stderr << "\n\n"
        raise OptionParser::MissingOption.new(flag)
      end
    end

    def parse(argv) : Option
      @opt.parse(argv)
      if argv.empty? && (@option.action == Action::Compute || @option.action == Action::Check)
        help_message(stderr)
        raise NoFileSpecifiedError.new
      end
      @option.filenames = argv
      @option
    end

    def help_message(io : IO)
      @opt.to_s(io)
    end
  end
end
