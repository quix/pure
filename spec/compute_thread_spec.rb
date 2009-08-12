require File.dirname(__FILE__) + '/pure_spec_base'

describe "compute" do
  max_threads = 50
  describe "with number of threads 1..#{max_threads}" do
    it "should succeed" do
      mod = pure do
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
      end
      (1..max_threads).each { |n|
        mod.compute(n) { |s| s.area }.should == (20 + 5)*(30 + 5)  
      }
    end
  end
end
