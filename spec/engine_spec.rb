require File.dirname(__FILE__) + "/common"

describe "parse engine" do
  it "should be queryable" do
    pure do
      def f
      end
    end
    lambda {
      Pure.engine
    }.should_not raise_error
  end

  it "should be swappable" do
    previous = Pure.engine
    begin
      Pure.engine = :ruby_parser
      Pure.engine.should == :ruby_parser
    ensure
      Pure.engine = previous
    end
  end

  it "should have a default" do
    Pure.engine = nil
    pure do
      def f
      end
    end.compute(:f, 3)
    Pure.engine.should_not == nil
  end
end
