require File.dirname(__FILE__) + "/common"

describe "combining pure modules" do
  before :all do
    mod_a = @mod_a = pure do
      def area(width, height)
        width*height
      end
      
      def border
        5
      end
    end

    mod_b = @mod_b = pure do
      def width(border)
        20 + border
      end
      
      def height(border)
        30 + border
      end
    end
    
    combined = @combined = pure do
      include mod_a
      include mod_b
    end

    @combined_override = pure do
      include combined
      def border
        99
      end
    end
  end
  
  max_threads = 5

  it "should work with modules included into empty module" do
    (1..max_threads).each { |n|
      @combined.compute(:area, n).should == (20 + 5)*(30 + 5)  
    }
  end

  it "should work with modules included into overriding module" do
    (1..max_threads).each { |n|
      @combined_override.compute(:area, n).should == (20 + 99)*(30 + 99)  
    }
  end

  it "should work with one module included into another" do
    mod_b = @mod_b
    @mod_a.module_eval {
      include mod_b
    }
    (1..max_threads).each { |n|
      @mod_a.compute(:area, n).should == (20 + 5)*(30 + 5)  
    }
  end
end

