require File.dirname(__FILE__) + '/pure_spec_base'

require 'jumpstart'

describe "pure" do
  it "should not be available without require 'pure/dsl'" do
    code = %{
      begin
        pure do
        end
      rescue Exception => e
        unless e.is_a?(NameError)
          raise 'expected name error'
        end
        unless e.message =~ %r!undefined method \`pure\'!
          raise 'unmatched message'
        end
      end
    }
    lambda {
      Jumpstart::Ruby.run("-e", code)
    }.should_not raise_error
  end

  it "should be an alias of Pure.define" do
    Pure.define do
      def f
        33
      end
    end.compute(4).f.should == 33
  end

  it "should not allow `fun' outside of block" do
    lambda {
      pure do
      end.fun :x do
        33
      end
    }.should raise_error(NoMethodError)
  end

  describe "with subsequent `def' definitions" do
    it "should be accepted" do
      mod = pure do
        def f
          33
        end
      end

      mod.compute(4).f.should eql(33)

      mod.module_eval do
        def g
          44
        end
      end

      mod.compute(4).g.should eql(44)
    end
  end

  describe "with subsequent `fun' definitions" do
    it "should be accepted" do
      mod = pure do
        fun :f do
          33
        end
      end

      mod.compute(4).f.should eql(33)

      mod.module_eval do
        fun :g do
          44
        end
      end

      mod.compute(4).g.should eql(44)
    end
  end
end
