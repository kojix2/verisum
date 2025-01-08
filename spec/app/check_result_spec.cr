require "spec"
require "../../src/checksum/app/check_result"

describe CheckSum::App::CheckResult do
  it "initializes with default values" do
    result = CheckSum::App::CheckResult.new
    result.total.should eq 0
    result.pass.should eq 0
    result.mismatch.should eq 0
    result.error.should eq 0
  end

  it "initializes with given values" do
    result = CheckSum::App::CheckResult.new(10, 5, 3, 2)
    result.total.should eq 10
    result.pass.should eq 5
    result.mismatch.should eq 3
    result.error.should eq 2
  end

  it "converts to hash" do
    result = CheckSum::App::CheckResult.new(10, 5, 3, 2)
    result.to_h.should eq({total: 10, pass: 5, mismatch: 3, error: 2})
  end

  it "formats to string" do
    result = CheckSum::App::CheckResult.new(10, 5, 3, 2)
    r = result.to_s
    r.should contain("10 files")
    r.should contain("5 passes")
    r.should contain("3 mismatches")
    r.should contain("2 errors")
  end

  it "formats to string with singular" do
    result = CheckSum::App::CheckResult.new(1, 1, 1, 1)
    r = result.to_s
    r.should contain("1 file")
    r.should contain("1 pass")
    r.should contain("1 mismatch")
    r.should contain("1 error")
  end

  it "formats to string with zero" do
    result = CheckSum::App::CheckResult.new(0, 0, 0, 0)
    r = result.to_s
    r.should contain("0 files")
    r.should contain("0 passes")
    r.should contain("0 mismatches")
    r.should contain("0 errors")
  end

  it "formats to string with color" do
    v = Colorize.enabled?
    Colorize.enabled = true
    result = CheckSum::App::CheckResult.new(10, 5, 3, 2)
    r = result.to_s
    r.should contain("5 passes".colorize(:green).to_s)
    r.should contain("3 mismatches".colorize(:red).to_s)
    r.should contain("2 errors".colorize(:magenta).to_s)
    Colorize.enabled = v
  end

  it "formats to string without color" do
    result = CheckSum::App::CheckResult.new(0, 0, 0, 0)
    v = Colorize.enabled?
    Colorize.enabled = true
    r = result.to_s
    r.should contain("0 files")
    r.should contain("0 passes")
    r.should contain("0 mismatches")
    r.should contain("0 errors")
    r.should_not contain("0 passes".colorize(:green).to_s)
    r.should_not contain("0 mismatches".colorize(:red).to_s)
    r.should_not contain("0 errors".colorize(:magenta).to_s)
    Colorize.enabled = v
  end

  it "compares equality" do
    result1 = CheckSum::App::CheckResult.new(10, 5, 3, 2)
    result2 = CheckSum::App::CheckResult.new(10, 5, 3, 2)
    result3 = CheckSum::App::CheckResult.new(1, 1, 1, 1)
    result1.should eq result2
    result1.should_not eq result3
  end
end
