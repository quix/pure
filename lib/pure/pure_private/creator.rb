
require 'pure/pure_private/extractor'
require 'pure/pure_private/util'
require 'pure/pure_private/function_database'
require 'pure/pure_private/driver'

module Pure
  module PurePrivate
    module Creator
      extend Util

      FUNCTION_DATABASE = FunctionDatabase::FUNCTION_DATABASE

      module_function

      def define_compute(mod)
        singleton_class_of(mod).module_eval do
          define_method :compute do |root, opts|
            Driver.instance_compute(mod, root, opts)
          end
        end
      end

      def define_fun(mod, fun_mod)
        singleton_class_of(mod).module_eval do
          # TODO: jettison 1.8.6; remove @fun_mod, use |&block|
          @fun_mod = fun_mod
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
            spec = Extractor.extract(:fun, caller)
            FUNCTION_DATABASE[fun_mod][node_sym] = spec.merge(
              :name => node_sym,
              :args => child_syms,
              :origin => :fun
            )
            nil
          end
        end
      end

      def define_method_added(mod)
        singleton_class_of(mod).module_eval do
          define_method :method_added do |function_name|
            FUNCTION_DATABASE[mod][function_name] = (
              Extractor.extract(function_name, caller).merge(:origin => :def)
            )
          end
        end
      end

      def define_define_method(mod)
        singleton_class_of(mod).module_eval do
          def define_method(*args, &block)
            raise PurePrivate::NotImplementedError,
            "define_method called (use the `fun' method instead)"
          end
        end
      end

      def define_module(&block)
        mod = Module.new
        fun_mod = Module.new
        define_compute(mod)
        define_fun(mod, fun_mod)
        define_method_added(mod)
        define_define_method(mod)
        mod.module_eval(&block)
        mod.module_eval { include fun_mod }
        mod
      end
    end
  end
end
