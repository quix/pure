require File.dirname(__FILE__) + '/pure_spec_base'
require 'benchmark'

# factor out due to parsers changing
def create_timed_benchmark
  mod = pure do
    def root(a, b)
    end
    
    def a
      sleep(0.25)
    end
    
    def b
      sleep(0.25)
    end
  end
  lambda { |n|
    mod.compute(n)[:root]
  }
end

require 'rbconfig'

# uneven results in windows
unless RbConfig::CONFIG["host"] =~ %r!(mswin|cygwin|mingw)!
  describe "compute" do
    describe "with timed example" do
      it "should run with 1 thread" do
        compute = create_timed_benchmark
        Benchmark.measure { compute.call(1) }.real.should be_close(0.5, 0.1)
      end
      
      it "should be 2x faster with 2 threads" do
        compute = create_timed_benchmark
        Benchmark.measure { compute.call(2) }.real.should be_close(0.25, 0.05)
      end
    end
  end
end
