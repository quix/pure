require File.dirname(__FILE__) + "/common"

describe "two defs on the same line:" do
  it "should raise error" do
    lambda {
      pure do
        def x ; end ; def y ; end
      end
    }.should raise_error(Pure::PurePrivate::ParseError)
  end
end

describe "function missing:" do
  it "should raise error" do
    lambda {
      pure do
        def area(width, height)
          width*height
        end
        
        def width
          33
        end
      end.compute :area, :threads => 3
    }.should raise_error(Pure::PurePrivate::NoFunctionError)
  end
end

describe "bad arguments:" do
  it "should raise error when given nil" do
    lambda {
      pure do
        def f
        end
      end.compute nil, 33
    }.should raise_error(Pure::PurePrivate::ArgumentError)
  end

  it "should raise error when given something random" do
    lambda {
      pure do
        def f
        end
      end.compute 33, 33
    }.should raise_error(Pure::PurePrivate::ArgumentError)
  end

  it "should raise error when given a string" do
    lambda {
      pure do
        def f
        end
      end.compute "f", 33
    }.should raise_error(Pure::PurePrivate::ArgumentError)
  end
end

describe "`fun'" do
  describe "given hash of size != 1" do
    it "should raise error" do
      lambda {
        pure do
          fun :x => 1, :y => 2 do
          end
        end
      }.should raise_error(Pure::PurePrivate::ArgumentError)
    end
  end

  describe "given more than 1 argument" do
    it "should raise error" do
      lambda {
        pure do
          fun :x, :y do
          end
        end
      }.should raise_error(Pure::PurePrivate::ArgumentError)
    end
  end

  describe "with &block" do
    it "should raise error" do
      lambda {
        pure do
          fun :f, &lambda { 33 }
        end.compute(:f, :threads => 4).should == 33
      }.should raise_error(Pure::PurePrivate::ParseError)

      lambda {
        pure do
          t = lambda { 33 }
          fun :f, &t
        end.compute(:f, :threads => 4).should == 33
      }.should raise_error(Pure::PurePrivate::ParseError)
    end
  end
end

describe "calling define_method" do
  it "should raise error" do
    lambda {
      pure do
        define_method :area do |width, height|
          width*height
        end
        
        def width
          5
        end
        
        def height
          7
        end
      end.compute :area, 3
    }.should raise_error(Pure::PurePrivate::NotImplementedError)
  end
end
