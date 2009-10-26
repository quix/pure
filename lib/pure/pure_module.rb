
module Pure
  class PureModule < Module
    def initialize(parser, &block)  #:nodoc:
      @parsing_active = true
      @parser = parser
      super(&block)
    end

    #
    # call-seq: compute(overrides = {})
    #           compute(num_parallel, overrides = {})
    #           compute(worker, overrides = {})
    #
    # Initialize a computation.
    #
    # All three forms take an optional hash for overriding pure
    # functions.
    #
    # In the first form, Pure.worker is the worker for the computation
    # and Pure.worker decides the number of parallel computations.
    #
    # In the second form, Pure.worker is the worker for the
    # computation and _num_parallel_ is passed as a hint to
    # Pure.worker, which may accept or ignore the hint.
    #
    # In the third form, _worker_ is the worker for the computation
    # and _worker_ decides the number of parallel computations.
    #
    def compute(*args)
      overrides = args.last.is_a?(Hash) ? args.pop : Hash.new
      worker, num_parallel = (
        case args.size
        when 0
          [Pure.worker, nil]
        when 1
          if args[0].is_a? Integer
            [Pure.worker, args[0]]
          else
            [args[0], nil]
          end
        else
          raise ArgumentError, "wrong number of arguments"
        end
      )
      driver = Driver.new(worker, self, num_parallel, overrides)
      delegate = Delegate.new(driver)
      if block_given?
        yield delegate
      else
        delegate
      end
    end

    #
    # call-seq: fun name => [name_a, name_b,...] do |arg_a, arg_b,...|
    #             ...
    #           end
    #
    # Define a pure function whose name and/or argument names are
    # not known at compile time.
    #
    # The name of the pure function is the value of _name_.  The
    # names of the function arguments are _name_a_, _name_b_,...
    # The respective values of the function arguments are
    # _arg_a_,_arg_b_,...
    #
    # See README.rdoc for examples.
    #
    def fun(arg, &block)
      function_str, arg_data = parse_fun_arg(arg)
      arg_names = (
        if arg_data.is_a? Enumerable
          arg_data.map { |t| t.to_sym }
        else
          [arg_data.to_sym]
        end
      )
      function_name = function_str.to_sym
      deactivate_parsing {
        define_method(function_name, &block)
      }
      Extractor.record_function(self, :fun, function_name, arg_names, caller)
      nil
    end

    #
    # call-seq: fun_map name => enumerable do |elem|
    #             ...
    #           end
    #
    # Define an anonymous pure function which is applied to each
    # element of the given enumerable.  The pure function _name_
    # returns the result array.
    #
    # See README.rdoc for examples.
    #
    def fun_map(arg, &block)
      function_name, elems = parse_fun_arg(arg)

      function_name = function_name.to_sym
      elems = elems.to_a

      input_elem_names, output_elem_names = [:input, :output].map { |which|
        (0...elems.size).map { |index|
          "__elem_#{which}_#{index}_#{function_name}".to_sym
        }
      }

      entry = ExtractedFunctions[parser][self]
      code = Extractor.record_function(self, :fun, :__tmp, [], caller)[:code]
      entry.delete(:__tmp)
      
      fun function_name => output_elem_names do |*result|
        result
      end
      entry[function_name][:elems] = input_elem_names.zip(elems)

      output_elem_names.zip(input_elem_names) { |output, input|
        fun output => input do |*args|
          block.call(*args)
        end
        entry[output][:code] = code
      }
      nil
    end

    def method_added(function_name)  #:nodoc:
      super
      if @parsing_active
        Extractor.record_function(self, :def, function_name, nil, caller)
      end
    end

    def define_method(*args, &block)  #:nodoc:
      if @parsing_active
        raise DefineMethodError.new(*Util.file_line(caller.first))
      else
        super
      end
    end

    attr_reader :parser  #:nodoc:

    def deactivate_parsing  #:nodoc:
      @parsing_active = false
      begin
        yield
      ensure
        @parsing_active = true
      end
    end

    def each_function  #:nodoc:
      ancestors.each { |ancestor|
        if defs = ExtractedFunctions[parser][ancestor]
          defs.each_pair { |name, spec|
            yield name, spec
          }
        end
      }
    end

    def parse_fun_arg(arg)  #:nodoc:
      if arg.is_a? Hash
        unless arg.size == 1
          raise ArgumentError, "`fun' given hash of size != 1"
        end
        arg.to_a.first
      else
        [arg, []]
      end
    end

    # want 'fun' both documented and private; rdoc --all is bad
    rdoc_fun = :fun
    private rdoc_fun
  end
end
