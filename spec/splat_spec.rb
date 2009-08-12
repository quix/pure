require File.dirname(__FILE__) + '/pure_spec_base'

describe "splat" do
  it "should be allowed outside of pure" do
    Class.new do
      def f(*args)
      end
    end

    pure do
      def g
        44
      end
    end
  end
end

