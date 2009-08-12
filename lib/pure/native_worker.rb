
module Pure
  class NativeWorker  #:nodoc:
    attr_reader :num_parallel

    def define_function_begin(pure_module, num_parallel)
      @num_parallel = num_parallel || self.class.num_parallel
      @class = Class.new Names do
        include pure_module
      end
    end

    def define_function(spec)
      lambda { |*args|
        @class.new(spec[:name], spec[:args]).send(spec[:name], *args)
      }
    end

    def define_function_end
    end

    class << self
      attr_accessor :num_parallel
    end
    @num_parallel = 1
  end
end
