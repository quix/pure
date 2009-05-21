
require 'pure/pure_private/extractor'
require 'pure/pure_private/function_database'
require 'pure/pure_private/driver'
require 'pure/pure_private/error'

module Pure
  module PurePrivate
    module SingletonFeatures
      include FunctionDatabase

      def compute(root, opts)
        Driver.create_instance_and_compute(self, root, opts)
      end
      
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
        spec = Extractor.extract(fun_mod, :fun, caller)
        FUNCTION_DATABASE[fun_mod][node_sym] = spec.merge(
          :name => node_sym,
          :args => child_syms,
          :origin => :fun
        )
        nil
      end

      def method_added(function_name)
        FUNCTION_DATABASE[self][function_name] = (
          Extractor.extract(self, function_name, caller).merge(:origin => :def)
        )
      end

      def define_method(*args, &block)
        raise PurePrivate::NotImplementedError,
        "define_method called (use the `fun' method instead)"
      end
    end
  end
end
