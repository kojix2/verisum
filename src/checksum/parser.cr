require "option_parser"
require "colorize"

require "./option"
require "./exception"

module CheckSum
  class Parser
    class NoFileSpecifiedError < CheckSumError
      def initialize
        super("No files specified.")
      end
    end

    def initialize(@option : Option)
      @opt = OptionParser.new
      @opt.banner = <<-BANNER

        Program: checksum
        Version: #{VERSION}
        Source:  #{SOURCE}

        Usage: checksum [options] [path]
      BANNER

      @opt.on("-c", "--check", "Check the checksum") do
        @option.action = Action::Check
      end

      @opt.on("-a", "--algorithm ALGORITHM", "(md5|sha1|sha256|sha512) [auto]") do |algorithm|
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
            e = ArgumentError.new("Unknown algorithm: #{algorithm}")
            raise e
          end
      end

      @opt.on("-A", "--absolute", "Output absolute path [false]") do
        @option.absolute_path = true
      end

      @opt.on("-v", "--verbose", "Output checksums and errors, etc [false]") do
        @option.verbose = true
      end

      @opt.on("--no-clear", "Do not clear the line [false]") do
        @option.clear_line = false
      end

      @opt.on("--color WHEN", "when to use color (auto|always|never) [auto]") do |when_|
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

      @opt.on("--debug", "Print a backtrace on error") do
        CheckSumError.debug = true
      end

      @opt.on("-h", "--help", "Show this message") do
        @option.action = Action::Help
      end

      @opt.on("--version", "Show version") do
        @option.action = Action::Version
      end

      @opt.invalid_option do |flag|
        STDERR.puts "#{help_message}\n"
        raise OptionParser::InvalidOption.new(flag)
      end

      @opt.missing_option do |flag|
        STDERR.puts "#{help_message}\n"
        raise OptionParser::MissingOption.new(flag)
      end
    end

    def parse(argv)
      @opt.parse(argv)
      if argv.empty? && (@option.action == Action::Calculate || @option.action == Action::Check)
        STDERR.puts "#{help_message}\n"
        raise NoFileSpecifiedError.new
        exit(1)
      end
      @option.filenames = argv
      @option
    end

    def help_message
      @opt.to_s
    end
  end
end
