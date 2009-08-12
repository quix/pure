require File.dirname(__FILE__) + '/pure_spec_base'

describe "pure" do
  describe "function defined with splat (*) argument via `def'" do
    it "should raise error" do
      lambda {
        pure do
          def f(a, b, *stuff)
            stuff
          end
        end
      }.should raise_error(
        Pure::SplatError, %r!cannot use splat.*#{__FILE__}:8!
      )
    end
  end
end

