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
      }.should raise_error(Pure::PurePrivate::SplatError, %r!cannot use splat!)
    end
  end
end

