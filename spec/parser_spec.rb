require File.dirname(__FILE__) + '/pure_spec_base'

describe "parser" do
  describe "provided by user" do
    it "should be accepted by pure" do
      memo = nil
      parser = Class.new do
        define_method :extract do |*args|
          memo = args
          Hash.new
        end
        def name
          "SampleParser"
        end
      end.new
      mod = pure(parser) do
        def f(x, y)
        end
      end
      memo.should == [mod, :f, __FILE__, 17]
    end
  end
end
