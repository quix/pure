
require 'pure/def_parser'
require 'pure/util'
require 'comp_tree'

module Pure
  VERSION = "0.1.0"

  METHOD_DATABASE = Hash.new { |hash, key|
    hash[key] = Hash.new
  }

  module_function

  def define_compute(mod, method_database)
    Util.singleton_class_of(mod).module_eval do
      define_method :compute do |root, opts|
        num_threads = (opts.is_a?(Hash) ? opts[:threads] : opts).to_i
        instance = Class.new { include mod }.new
        CompTree.build do |driver|
          mod.ancestors.each { |ancestor|
            if defs = method_database[ancestor]
              defs.each_pair { |method_name, args|
                existing_node = driver.nodes[method_name]
                if existing_node.nil? or existing_node.function.nil?
                  driver.define(method_name, *args) { |*objs|
                    instance.send(method_name, *objs)
                  }
                end
              }
            end
          }
          driver.compute(root, num_threads)
        end
      end
    end
  end

  def define_fun(mod, fun_mod, method_database)
    Util.singleton_class_of(mod).module_eval do
      define_method :fun do |*args, &fun_block|
        node_name, child_names = (
          if args.size == 1
            arg = args.first
            if arg.is_a? Hash
              unless arg.size == 1
                raise ArgumentError, "`fun' given hash of size != 1"
              end
              arg.to_a.first
            else
              [arg, []]
            end
          else
            raise ArgumentError,
            "wrong number of arguments (\#{args.size} for 1)"
          end
        )
        child_syms = (
          if child_names.is_a? Enumerable
            child_names.map { |t| t.to_sym }
          else
            child_names.to_sym
          end
        )
        node_sym = node_name.to_sym
        fun_mod.module_eval {
          define_method(node_sym, &fun_block)
        }
        method_database[fun_mod][node_sym] = child_syms
        nil
      end
    end
  end

  def define_method_added(mod, method_database)
    Util.singleton_class_of(mod).module_eval do
      define_method :method_added do |method_name|
        file, line = DefParser.file_line(caller)
        method_database[mod][method_name] = (
          DefParser.parse(mod, method_name, file, line)
        )
      end
    end
  end

  def pure(&block)
    mod = Module.new
    fun_mod = Module.new
    define_compute(mod, METHOD_DATABASE)
    define_fun(mod, fun_mod, METHOD_DATABASE)
    define_method_added(mod, METHOD_DATABASE)
    mod.module_eval(&block)
    mod.module_eval { include fun_mod }
    mod
  end
end

