require "./spec_helper"

describe CheckSum::Parser do
  it "raises an error when no files are specified" do
    parser = CheckSum::Parser.new
    expect_raises CheckSum::Parser::NoFileSpecifiedError do
      parser.parse([] of String)
    end
  end
end
