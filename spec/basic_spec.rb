require File.dirname(__FILE__) + "/common"

describe "basic computation" do
  before :all do
    @mod = Module.new {
      include Pure
      
      def area(width, height)
        width*height
      end
      
      def width(border)
        20 + border
      end
      
      def height(border)
        30 + border
      end
      
      def border
        5
      end
    }
  end
  
  max_threads = 50
  it "should run using compute(:x, :threads => n) syntax" do
    (1..max_threads).each { |n|
      @mod.compute(:area, :threads => n).should == (20 + 5)*(30 + 5)  
    }
  end
  it "should run using compute(:x, n) syntax" do
    (1..max_threads).each { |n|
      @mod.compute(:area, n).should == (20 + 5)*(30 + 5)  
    }
  end
end

