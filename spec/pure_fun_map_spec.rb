require File.dirname(__FILE__) + '/pure_spec_base'

require 'thread'
require 'benchmark'

describe "pure" do
  describe "fun_map" do
    it "should map the given array" do
      pure do
        fun_map :squares => 3..5 do |n|
          n**2
        end
      end.compute(3).squares.should == [9, 16, 25]
    end

    it "should map in parallel" do
      mod = pure do
        fun_map :sleeper => (1..3).to_a do |n|
          sleep(0.2)
        end
      end
      epsilon = 0.10 + (RUBY_PLATFORM == "java" ? 99 : 0)
      mod.compute(1) { |result|
        Benchmark.measure { result.sleeper }.real.should be_close(0.6, epsilon)
      }
      mod.compute(2) { |result|
        Benchmark.measure { result.sleeper }.real.should be_close(0.4, epsilon)
      }
      mod.compute(3) { |result|
        Benchmark.measure { result.sleeper }.real.should be_close(0.2, epsilon)
      }
      mod.compute(4) { |result|
        Benchmark.measure { result.sleeper }.real.should be_close(0.2, epsilon)
      }
      mod.compute(5) { |result|
        Benchmark.measure { result.sleeper }.real.should be_close(0.2, epsilon)
      }
    end

    it "should accept empty array" do
      pure do
        fun_map :squares => [] do |n|
          n**2
        end
      end.compute(3).squares.should == []
    end

    it "should accept empty enum" do
      pure do
        fun_map :squares => 9...9 do |n|
          n**2
        end
      end.compute(3).squares.should == []
    end

    it "should raise error when given hash of size != 1" do
      lambda {
        pure do
          fun_map :x => 1, :y => 2 do
          end
        end
      }.should raise_error(ArgumentError)
    end

    it "should raise error given more than 1 argument" do
      lambda {
        pure do
          fun_map :x, :y do
          end
        end
      }.should raise_error(ArgumentError)
    end
  end
end

