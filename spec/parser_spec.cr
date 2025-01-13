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

  it "parses the -c flag correctly" do
    parser = CheckSum::Parser.new
    option = parser.parse(["-c", "file"])
    option.action.should eq CheckSum::Action::Compute
  end

  it "parses the -a flag with valid algorithm" do
    parser = CheckSum::Parser.new
    option = parser.parse(["-a", "md5", "file"])
    option.algorithm.should eq CheckSum::Algorithm::MD5
  end

  it "raises an error for invalid algorithm" do
    parser = CheckSum::Parser.new
    expect_raises ArgumentError do
      parser.parse(["-a", "invalid", "file"])
    end
  end

  it "parses the -A flag correctly" do
    parser = CheckSum::Parser.new
    option = parser.parse(["-A", "file"])
    option.absolute_path?.should be_true
  end

  it "parses the -v flag correctly" do
    parser = CheckSum::Parser.new
    option = parser.parse(["-v", "file"])
    option.verbose?.should be_true
  end

  it "parses the -N flag correctly" do
    parser = CheckSum::Parser.new
    option = parser.parse(["-N", "file"])
    option.clear_line?.should be_false
  end

  it "parses the -C flag with auto" do
    parser = CheckSum::Parser.new
    parser.parse(["-C", "auto", "file"])
    Colorize.enabled?.should eq STDOUT.tty?
  end

  it "parses the -C flag with always" do
    parser = CheckSum::Parser.new
    parser.parse(["-C", "always", "file"])
    Colorize.enabled?.should be_true
  end

  it "parses the -C flag with never" do
    parser = CheckSum::Parser.new
    parser.parse(["-C", "never", "file"])
    Colorize.enabled?.should be_false
  end

  it "raises an error for invalid color mode" do
    parser = CheckSum::Parser.new
    expect_raises ArgumentError do
      parser.parse(["-C", "invalid", "file"])
    end
  end

  it "parses the -D flag correctly" do
    parser = CheckSum::Parser.new
    parser.parse(["-D", "file"])
    CheckSum::CheckSumError.debug?.should be_true
  end

  it "parses the -h flag correctly" do
    parser = CheckSum::Parser.new
    option = parser.parse(["-h"])
    option.action.should eq CheckSum::Action::Help
  end

  it "parses the -V flag correctly" do
    parser = CheckSum::Parser.new
    option = parser.parse(["-V"])
    option.action.should eq CheckSum::Action::Version
  end

  it "raises an error for invalid option" do
    parser = CheckSum::Parser.new
    parser.stderr = IO::Memory.new
    expect_raises OptionParser::InvalidOption do
      parser.parse(["--invalid"])
    end
  end

  it "raises an error for missing option argument" do
    parser = CheckSum::Parser.new
    parser.stderr = IO::Memory.new
    expect_raises OptionParser::MissingOption do
      parser.parse(["-a"])
    end
  end
end
