require "spec"
require "../src/verisum/redirect"

class TestObject
  include Verisum::Redirect

  def public_print(*args)
    print(*args)
  end

  def public_puts(*args)
    puts(*args)
  end
end

describe Verisum::Redirect do
  it "has a default stdout" do
    redirect = TestObject.new
    redirect.stdout.should eq(STDOUT)
  end

  it "has a default stderr" do
    redirect = TestObject.new
    redirect.stderr.should eq(STDERR)
  end

  it "redirects print to custom stdout" do
    io = IO::Memory.new
    redirect = TestObject.new
    redirect.stdout = io

    redirect.public_print "Hello, world!"
    io.rewind

    io.gets(chomp: false).should eq("Hello, world!")
  end

  it "redirects puts to custom stdout" do
    io = IO::Memory.new
    redirect = TestObject.new
    redirect.stdout = io

    redirect.public_puts "Hello, world!"
    io.rewind

    io.gets(chomp: false).should eq("Hello, world!\n")
  end

  it "redirects print to custom stderr" do
    io = IO::Memory.new
    redirect = TestObject.new
    redirect.stderr = io

    redirect.stderr.print "Error message"
    io.rewind

    io.gets(chomp: false).should eq("Error message")
  end

  it "handles empty strings in print" do
    io = IO::Memory.new
    redirect = TestObject.new
    redirect.stdout = io

    redirect.public_print ""
    io.rewind

    io.gets.should be_nil
  end

  it "handles multiple arguments in print" do
    io = IO::Memory.new
    redirect = TestObject.new
    redirect.stdout = io

    redirect.public_print "Hello", ", ", "world!"
    io.rewind

    io.gets(chomp: false).should eq("Hello, world!")
  end
end
