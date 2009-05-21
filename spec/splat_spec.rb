require File.dirname(__FILE__) + "/common"

describe "splat (*) argument in pure function" do
  describe "with `def'" do
    it "should raise error" do
      lambda {
        pure do
          def f(a, b, *stuff)
            stuff
          end
        end
      }.should raise_error(Pure::PurePrivate::SplatError)
    end
  end

  describe "with `fun'" do
    it "should work in block args" do
      pure do
        fun :area => [:width, :height] do |*a|
          a[0]*a[1]
        end
        
        def width
          3
        end
        
        def height
          4
        end
      end.compute(:area, 3).should == 12
    end

    it "should work for single-element array" do
      pure do
        name = [:f]
        fun(*name) do
          name
        end
      end.compute(:f, 3).should == [:f]
    end
  end
end

