require File.dirname(__FILE__) + "/common"

describe "`fun' definitions" do
  before :all do
    @normal = pure do
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
    end

    @mixed = pure do
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
    end
  end
  
  it "should work with symbols only" do
    @normal.compute(:area, :threads => 4).should == (20 + 5)*(30 + 5)
  end

  it "should work with mixed symbols and strings" do
    @mixed.compute(:area, :threads => 4).should == (20 + 5)*(30 + 5)
  end
end
