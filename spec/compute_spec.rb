require File.dirname(__FILE__) + '/pure_spec_base'

describe "compute" do
  it "should accept no arguments" do
    pure do
      def f
        33
      end
    end.compute.f.should == 33
  end

  it "should accept (overrides) argument" do
    pure do
      def f
        33
      end
    end.compute(:f => 44).f.should == 44
  end
  it "should accept (num_parallel) argument" do
    (1..8).each { |n|
      pure do
        def f
          33
        end
      end.compute(n).f.should == 33
    }
  end
  it "should accept (worker) argument" do
    pure do
      def f
        33
      end
    end.compute(Pure::NativeWorker).f.should == 33
  end
  it "should accept (num_parallel, overrides) arguments" do
    (1..8).each { |n|
      pure do
        def f
          33
        end
      end.compute(n, :f => 99).f.should == 99
    }
  end
  it "should accept (worker, overrides) arguments" do
    pure do
      def f
        33
      end
    end.compute(Pure::NativeWorker, :f => 99).f.should == 99
  end
  it "should raise error for > 2 arguments" do
    lambda {
      pure do
        def f
          33
        end
      end.compute(:a, :b, :c).f.should == 99
    }.should raise_error(ArgumentError)
  end
  it "should raise #{Pure::NoFunctionError} for undefined function" do
    (1..8).each { |n|
      lambda {
        result = pure do
          def f(x)
            x + 33
          end
        end.compute(n).f
      }.should raise_error(Pure::NoFunctionError, "no function named `x'")
    }
  end
  it "should be independent of other compute calls" do
    mod_f1 = pure do
      def f
        1
      end
    end
    mod_f2 = pure do
      def f
        2
      end
    end
    result_f1 = mod_f1.compute(3)
    result_f2 = mod_f2.compute(4)
    result_f1.f.should == 1
  end
end
