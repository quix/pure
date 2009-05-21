require File.dirname(__FILE__) + "/common"

describe "splat (*) argument in pure function" do
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
