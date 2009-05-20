require File.dirname(__FILE__) + "/common"

describe "parse engine" do
  it "should be queryable" do
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

  it "should have a default" do
    Pure.instance_eval { @parser = nil }
    pure do
      def f
      end
    end
    Pure.parser.should_not == nil
  end
end
