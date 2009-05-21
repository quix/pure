require File.dirname(__FILE__) + "/common"

describe "parse engine" do
  it "should be queryable" do
    pure do
      def f
      end
    end
    lambda {
      Pure.parser
    }.should_not raise_error
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

  it "should have a default unless Method#parameters available" do
    Pure.parser = nil
    pure do
      def f
      end
    end.compute(:f, 3)
    if Method.instance_methods.include?(:parameters)
      Pure.parser.should == nil
    else
      Pure.parser.should_not == nil
    end
  end
end
