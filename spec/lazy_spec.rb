require File.dirname(__FILE__) + "/common"

LAZY_SPEC_COUNTER = Struct.new(:value).new

describe "laziness" do
  it "should be lazy" do
    LAZY_SPEC_COUNTER.value = 0

    mod = pure do
      def square(n)
        n*n
      end
      
      def n
        LAZY_SPEC_COUNTER.value += 1
        3
      end
    end.compute :square, :threads => 4

    LAZY_SPEC_COUNTER.value.should == 1
  end
end
