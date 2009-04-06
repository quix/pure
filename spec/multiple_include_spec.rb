require File.dirname(__FILE__) + "/../spec/common"

describe "subsequent `include Pure'" do
  it "should be ignored" do
    lambda {
      Module.new do
        include Pure
        def f
        end
        include Pure
        def g
        end
      end
    }.should_not raise_error
  end
end
