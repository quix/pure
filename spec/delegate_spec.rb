require File.dirname(__FILE__) + '/pure_spec_base'

if RUBY_PLATFORM == "java"
  # jruby needs this here; don't know why
  require 'ruby2ruby'
end

def create_geometry_example
  pure do
    def area(width, height)
      width*height
    end
    
    def width(border)
      7 + border
    end
    
    def height(border)
      5 + border
    end
  end.compute(4, :border => 2)
end

describe Pure::Delegate do
  it "should hold results" do
    geometry = create_geometry_example
    geometry.area.should eql((7 + 2)*(5 + 2))
    geometry.width.should eql(7 + 2)
    geometry.height.should eql(5 + 2)
    geometry.border.should eql(2)
  end

  it "should raise error for undefined attribute" do
    lambda {
      pure do
        def f
          33
        end
      end.compute.g
    }.should raise_error(NoMethodError)
  end

  it "should raise error when attribute is passed args" do
    lambda {
      pure do
        def f
          33
        end
      end.compute.f(44)
    }.should raise_error(ArgumentError)
  end

  it "should be lazy" do
    mutex = Mutex.new
    counter = 0
    incrementer = pure do
      fun :increment do
        mutex.synchronize {
          counter += 1
        }
      end
    end.compute(Pure::NativeWorker)
    counter.should eql(0)
    3.times {
      incrementer.increment.should eql(1)
    }
  end

  describe "[] alternative to method call" do
    it "should accept symbols" do
      geometry = create_geometry_example
      geometry[:area].should eql((7 + 2)*(5 + 2))
      geometry[:width].should eql(7 + 2)
      geometry[:height].should eql(5 + 2)
      geometry[:border].should eql(2)
    end

    it "should accept strings" do
      geometry = create_geometry_example
      geometry["area"].should eql((7 + 2)*(5 + 2))
      geometry["width"].should eql(7 + 2)
      geometry["height"].should eql(5 + 2)
      geometry["border"].should eql(2)
    end

    it "should raise error if given > 1 arg" do
      geometry = create_geometry_example
      lambda {
        geometry[:area, 4]
      }.should raise_error(ArgumentError)
    end

    it "should raise error when given other types" do
      lambda {
        pure do
          def f
          end
        end.compute(33)[nil]
      }.should raise_error(TypeError)

      lambda {
        pure do
          def f
          end
        end.compute(33)[Object.new]
      }.should raise_error(TypeError)
    end

    it "should propagate exceptions from root function" do
      mod = pure do
        def f
          raise "zz"
        end
      end
      result = mod.compute(4)
      lambda {
        result.f
      }.should raise_error(RuntimeError, "zz")
    end

    it "should propagate exceptions from child functions" do
      mod = pure do
        def f(x)
          33
        end

        def x(y)
          44
        end

        def y
          raise "foo"
        end
      end
      result = mod.compute(4)
      lambda {
        result.f
      }.should raise_error(RuntimeError, "foo")
    end
  end
end
