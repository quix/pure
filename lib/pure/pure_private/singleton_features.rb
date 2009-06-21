
require 'pure/pure_private/extractor'
require 'pure/pure_private/function_database'
require 'pure/pure_private/driver'
require 'pure/pure_private/error'

module Pure
  module PurePrivate
    #
    # A pure module (returned by Pure.pure) has these singleton
    # methods.
    #
    module SingletonFeatures
      #
      # call-seq: compute(root, n)
      #           compute(root, :threads => n)
      #
      # Compute a pure function with _n_ threads.
      #
      def compute(root, opts)
        Driver.create_instance_and_compute(self, root, opts)
      end
      
      #
      # call-seq: fun label => [label_a, label_b,...] do |arg_a, arg_b,...|
      #             ...
      #           end
      #
      # Define a pure function whose name and/or argument names are
      # not known at compile time.
      #
      # The name of the pure function is the value of _label_.  The
      # names of the function arguments are _label_a_, _label_b_,....
      # These are assigned to _arg_a_,_arg_b_,... respectively in the
      # block.
      #
      # Example:
      #
      #   require 'rubygems'
      #   require 'pure'
      #   include Pure
      #   
      #   stats = pure do
      #     files = Dir["*"]
      #   
      #     files.each { |file|
      #       fun file do
      #         File.size(file)
      #       end
      #     }
      #   
      #     fun :total_size => files do |*sizes|
      #       sizes.inject(0) { |acc, size| acc + size }
      #     end
      #   end
      #   
      #   p stats.compute(:total_size, 3)
      #
      def fun(*args, &block)
        fun_mod = class << self ; @fun_mod ; end
        node_name, child_names = (
          if args.size == 1
            arg = args.first
            if arg.is_a? Hash
              unless arg.size == 1
                raise PurePrivate::ArgumentError,
                "`fun' given hash of size != 1"
              end
              arg.to_a.first
            else
              [arg, []]
            end
          else
            raise PurePrivate::ArgumentError,
            "wrong number of arguments (\#{args.size} for 1)"
          end
        )
        child_syms = (
          if child_names.is_a? Enumerable
            child_names.map { |t| t.to_sym }
          else
            [child_names.to_sym]
          end
        )
        node_sym = node_name.to_sym
        fun_mod.module_eval {
          define_method(node_sym, &block)
        }
        spec = Extractor.extract(fun_mod, :__fun, caller)
        FunctionDatabase[fun_mod][node_sym] = spec.merge(
          :name => node_sym,
          :args => child_syms,
          :origin => :fun
        )
        nil
      end

      def method_added(function_name)  #:nodoc:
        FunctionDatabase[self][function_name] = (
          Extractor.extract(self, function_name, caller).merge(:origin => :def)
        )
      end

      def define_method(*args, &block)  #:nodoc:
        raise PurePrivate::NotImplementedError,
        "define_method called (use the `fun' method instead)"
      end
    end
  end
end
