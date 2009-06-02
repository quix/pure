require File.dirname(__FILE__) + "/common"

describe "subsequent `def' definitions" do
  it "should be accepted" do
    mod = pure do
      def f
        33
      end
    end

    mod.compute(:f, 4).should eql(33)

    mod.module_eval do
      def g
        44
      end
    end

    mod.compute(:g, 4).should eql(44)
  end
end

describe "subsequent `fun' definitions" do
  it "should be accepted" do
    mod = pure do
      fun :f do
        33
      end
    end

    mod.compute(:f, 4).should eql(33)

    mod.module_eval do
      fun :g do
        44
      end
    end

    mod.compute(:g, 4).should eql(44)
  end
end

