require "spec"
require "../../src/verisum/app/utils"

class TestUtilsClass
  include Verisum::App::Utils

  def format_time_span2(span)
    format_time_span(span)
  end
end

describe Verisum::App::Utils do
  utils = TestUtilsClass.new

  it "formats time span less than a minute" do
    span = Time::Span.new(seconds: 45) # 45 seconds
    utils.format_time_span2(span).should eq "45.0s"
  end

  it "formats time span more than a minute" do
    span = Time::Span.new(minutes: 1, seconds: 45) # 1 minute 45 seconds
    utils.format_time_span2(span).should eq "1m 45s"
  end

  it "formats long time spans correctly" do
    span = Time::Span.new(minutes: 1000, seconds: 45) # 1000 minutes 45 seconds
    utils.format_time_span2(span).should eq "16h 40m 45s"
  end

  it "formats zero seconds correctly" do
    span = Time::Span.new(seconds: 0)
    utils.format_time_span2(span).should eq "0.00s"
  end

  it "formats exactly 10 seconds" do
    span = Time::Span.new(seconds: 10)
    utils.format_time_span2(span).should eq "10.0s"
  end

  it "formats exactly 1 minute" do
    span = Time::Span.new(minutes: 1)
    utils.format_time_span2(span).should eq "1m"
  end

  it "formats exactly 1 hour" do
    span = Time::Span.new(hours: 1)
    utils.format_time_span2(span).should eq "1h"
  end

  it "formats 1 hour and 45 seconds correctly" do
    span = Time::Span.new(hours: 1, seconds: 45)
    utils.format_time_span2(span).should eq "1h 45s"
  end

  it "formats very large time spans correctly" do
    span = Time::Span.new(hours: 100)
    utils.format_time_span2(span).should eq "100h"
  end

  it "does not show zero seconds unnecessarily" do
    span = Time::Span.new(minutes: 1, seconds: 0)
    utils.format_time_span2(span).should eq "1m"
  end

  it "does not show zero minutes unnecessarily" do
    span = Time::Span.new(hours: 2, minutes: 0, seconds: 0)
    utils.format_time_span2(span).should eq "2h"
  end

  it "removes bom from string" do
    utils.remove_bom("\xEF\xBB\xBFHello").should eq "Hello"
  end

  it "removes bom from string with no bom" do
    utils.remove_bom("Hello").should eq "Hello"
  end

  it "removes bom from string with no bom" do
    utils.remove_bom("Hello").should eq "Hello"
  end

  it "removes UTF-16 (BE) BOM from string" do
    utils.remove_bom("\xFE\xFFHello").should eq "Hello"
  end

  it "removes UTF-16 (LE) BOM from string" do
    utils.remove_bom("\xFF\xFEHello").should eq "Hello"
  end

  it "removes UTF-32 (BE) BOM from string" do
    utils.remove_bom("\x00\x00\xFE\xFFHello").should eq "Hello"
  end

  it "removes UTF-32 (LE) BOM from string" do
    utils.remove_bom("\xFF\xFE\x00\x00Hello").should eq "Hello"
  end

  it "does not remove BOM if not present" do
    utils.remove_bom("Hello").should eq "Hello"
  end
end
