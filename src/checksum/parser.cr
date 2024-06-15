require "option_parser"
require "colorize"

require "./option"
require "./exception"

module CheckSum
  class Parser
    def initialize(@option : Option)
      @opt = OptionParser.new
      @opt.banner = "Usage: checksum [options]"

      @opt.on("-c", "--check FILE", "Read checksums from the FILE (required)") do |n|
        @option.action = Action::Check
        @option.filename = n
      end

      @opt.on("-a", "--algorithm ALGORITHM", "(md5|sha1|sha256|sha512|auto)") do |algorithm|
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

      @opt.on("-v", "--verbose", "Verbose mode [false]") do
        @option.verbose = true
      end

      @opt.on("--no-clear", "Do not clear the line [false]") do
        @option.clear_line = false
      end

      @opt.on("--no-color", "Do not use color [false]") do
        Colorize.enabled = false
      end

      @opt.on("--debug", "Debug mode [false]") do
        CheckSumError.debug = true
      end

      @opt.on("--help", "Show this message") do
        @option.action = Action::Help
      end

      @opt.on("--version", "Show version") do
        @option.action = Action::Version
      end

      @opt.invalid_option do |flag|
        STDERR.puts "[checksum] ERROR: #{flag} is not a valid option."
        STDERR.puts self
        exit(1)
      end
    end

    def parse(argv)
      @opt.parse(argv)
      @option
    end

    def help
      @opt.to_s
    end
  end
end
