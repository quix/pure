require File.dirname(__FILE__) + "/common"

describe "`fun' definitions" do
  it "should work with symbols only" do
    pure do
      fun :area => [:width, :height] do |w, h|
        w*h
      end
      
      fun :width => [:border] do |b|
        20 + b
      end
      
      fun :height => :border do |b|
        30 + b
      end
      
      fun :border do
        5
      end
    end.compute(:area, :threads => 4).should == (20 + 5)*(30 + 5)
  end

  it "should work with symbols and parens only" do
    pure do
      fun(:area => [:width, :height]) do |w, h|
        w*h
      end
      
      fun(:width => [:border]) do |b|
        20 + b
      end
      
      fun(:height => :border) do |b|
        30 + b
      end
      
      fun(:border) do
        5
      end
    end.compute(:area, :threads => 4).should == (20 + 5)*(30 + 5)
  end

  it "should work with mixed symbols and strings" do
    pure do
      fun :area => [:width, "height"] do |w, h|
        w*h
      end
      
      fun "width" => [:border] do |b|
        20 + b
      end
      
      fun :height => "border" do |b|
        30 + b
      end
      
      fun :border do
        5
      end
    end.compute(:area, :threads => 4).should == (20 + 5)*(30 + 5)
  end

  it "should work with `def' definitions" do
    pure do
      fun :width do
        33
      end
      
      def height
        44
      end

      fun :area => [:width, :height] do |w, h|
        w*h
      end
    end.compute(:area, 3).should == 33*44
  end

  it "should be lower precedence than `def' definitions" do
    pure do
      fun :f do
        44
      end
    end.compute(:f, 10).should eql(44)

    pure do
      fun :f do
        44
      end

      def f
        33
      end
    end.compute(:f, 10).should eql(33)
  end

  it "should support splat in block args" do
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

  it "should support splat with single-element array" do
    pure do
      name = [:f]
      fun(*name) do
        name
      end
    end.compute(:f, 3).should == [:f]
  end

  it "should not preclude `def' definitions called `fun'" do
    pure do
      def amuse(fun)
        fun*2
      end

      def fun(a, b)
        a + b
      end

      def a
        3
      end

      def b
        5
      end
    end.compute(:amuse, 3).should == 16
  end
end
