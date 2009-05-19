require File.dirname(__FILE__) + "/common"

describe "parser choice" do
  it "should raise error when not installed" do
    lambda { Pure.parser = "z"*99 }.should raise_error(LoadError)
  end

  it "should raise error when unsupported" do
    lambda { Pure.parser = "fileutils" }.should raise_error
  end

  it "should be queryable" do
    # force default if not yet chosen
    pure do
      def f
      end
    end
    Pure.parser.should_not == nil
  end

  it "should be swappable" do
    previous = Pure.parser
    begin
      Pure.parser = "ruby_parser"
      Pure.parser.should == "ruby_parser"
    ensure
      Pure.parser = previous
    end
  end
end
