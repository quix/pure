require File.dirname(__FILE__) + "/common"
require 'benchmark'

describe "timed example" do
  before :all do
    @mod = Module.new do
      include Pure

      def root(a, b)
      end
        
      def a
        sleep(0.25)
      end

      def b
        sleep(0.25)
      end
    end
    @compute = lambda { |n|
      @mod.compute :root, n
    }
  end

  it "should run with 1 thread" do
    Benchmark.measure { @compute.call(1) }.real.should be_close(0.5, 0.01)
  end

  it "should be 2x faster with 2 threads" do
    Benchmark.measure { @compute.call(2) }.real.should be_close(0.25, 0.01)
  end
end
