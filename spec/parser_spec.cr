require "spec"
require "../src/checksum/parser"

describe CheckSum::Parser do
  it "raises an error when no files are specified" do
    parser = CheckSum::Parser.new
    parser.stderr = IO::Memory.new
    expect_raises CheckSum::Parser::NoFileSpecifiedError do
      parser.parse([] of String)
    end
  end

  it "builds a help message" do
    parser = CheckSum::Parser.new
    io = IO::Memory.new
    parser.help_message(io)
    io.rewind
    msg = io.gets_to_end
    msg.should contain("Program:")
    msg.should contain("Version:")
    msg.should contain("Usage:")
    msg.should contain("-N, --no-clear")
    msg.should contain("-h, --help")
  end
end
