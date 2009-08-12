require File.dirname(__FILE__) + '/pure_spec_base'

require 'thread'

def create_worker
  memo = Array.new
  mutex = Mutex.new

  worker = Class.new do
    define_method :define_function_begin do |pure_mod, num_parallel|
      memo.push [:begin, pure_mod, num_parallel]
    end

    define_method :define_function do |*args|
      lambda { |*a|
        mutex.synchronize {
          memo.push args
        }
      }
    end

    define_method :define_function_end do
      memo.push :end
    end

    def num_parallel
      3
    end
  end

  mod = pure do
    def f(x)
      33
    end
    def x
      9
    end
  end

  [worker, mod, memo]
end

def check_function_specs(mod, memo, num_parallel)
  memo[0].should eql([:begin, mod, num_parallel])
  memo[1].should eql(:end)

  memo[2].should be_a(Array)
  memo[2].size.should eql(1)
  memo[2][0].should be_a(Hash)

  memo[3].should be_a(Array)
  memo[3].size.should eql(1)
  memo[3][0].should be_a(Hash)

  names = [memo[2][0][:name], memo[3][0][:name]]
  names.map { |t| t.to_s }.sort.should eql(["f", "x"])
  f_index = 2 + names.index(:f)
  x_index = 2 + names.index(:x)

  memo[x_index][0][:origin].should eql(:def)
  memo[x_index][0][:name].should eql(:x)
  memo[x_index][0][:args].should eql([])

  memo[f_index][0][:origin].should eql(:def)
  memo[f_index][0][:name].should eql(:f)
  memo[f_index][0][:args].should eql([:x])
end

describe "worker" do
  it "should be given function specs" do
    worker, mod, memo = create_worker
    Pure.worker.object_id.should_not eql(worker.object_id)
    mod.compute(worker).f
    Pure.worker.object_id.should_not eql(worker.object_id)
    check_function_specs(mod, memo, nil)
  end

  it "should be given num_parallel hint" do
    worker, mod, memo = create_worker
    previous = Pure.worker
    Pure.worker = worker
    begin
      mod.compute(11).f
      check_function_specs(mod, memo, 11)
    ensure
      Pure.worker = previous
    end
  end
end
