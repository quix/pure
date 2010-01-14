require File.dirname(__FILE__) + '/pure_spec_base'

describe "simple example" do
  it "should work" do
    geometry = pure do
      def area(width, height)
        width*height
      end
      
      def width(border)
        7 + border
      end
      
      def height(border)
        5 + border
      end
      
      def border
        2
      end
    end
    
    geometry.compute(3).area.should == 63
  end
end
