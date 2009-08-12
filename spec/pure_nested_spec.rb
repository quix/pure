require File.dirname(__FILE__) + '/pure_spec_base'

describe "pure" do
  describe "with nested defs" do
    it "should work with different names" do
      Class.new do
        def f(n)
          pure do
            def g(h)
              h**2
            end
            fun :h do
              n
            end
          end.compute(Pure::NativeWorker).g
        end
      end.new.f(5).should == 25
    end

    it "should work with the same name" do
      Class.new do
        def f(n)
          pure do
            def f(h)
              h**2
            end
            fun :h do
              n
            end
          end.compute(Pure::NativeWorker).f
        end
      end.new.f(5).should == 25
    end
  end
end
