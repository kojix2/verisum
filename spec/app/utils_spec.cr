require "spec"
require "../../src/checksum/app/utils"

class TestUtilsClass
  include CheckSum::App::Utils

  def format_time_span2(span)
    format_time_span(span)
  end
end

describe CheckSum::App::Utils do
  it "formats time span less than a minute" do
    utils = TestUtilsClass.new
    span = Time::Span.new(seconds: 45) # 45 seconds
    utils.format_time_span2(span).should eq "45.0s"
  end

  it "formats time span more than a minute" do
    utils = TestUtilsClass.new
    span = Time::Span.new(minutes: 1, seconds: 45) # 1 minute 45 seconds
    utils.format_time_span2(span).should eq "1m 45s"
  end

  it "formats long time spans correctly" do
    utils = TestUtilsClass.new
    span = Time::Span.new(minutes: 1000, seconds: 45) # 1000 minutes 45 seconds
    utils.format_time_span2(span).should eq "16h 40m 45s"
  end

  it "removes bom from string" do
    utils = TestUtilsClass.new
    utils.remove_bom("\xEF\xBB\xBFHello").should eq "Hello"
  end

  it "removes bom from string with no bom" do
    utils = TestUtilsClass.new
    utils.remove_bom("Hello").should eq "Hello"
  end
end
