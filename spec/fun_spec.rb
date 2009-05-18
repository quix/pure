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
    end.compute(:f, 10).should == 44

    pure do
      fun :f do
        44
      end

      def f
        33
      end
    end.compute(:f, 10).should == 33
  end
end
