require File.dirname(__FILE__) + "/common"

describe "`fun' definitions" do
  before :all do
    @mod = Module.new {
      include Pure
      
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
    }
  end
  
  it "should work" do
    @mod.compute(:area, :threads => 1).should == (20 + 5)*(30 + 5)
  end
end
