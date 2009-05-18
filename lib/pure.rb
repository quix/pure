
require 'pure/def_parser'
require 'pure/util'
require 'comp_tree'

module Pure
  VERSION = "0.1.0"

  module_function

  def pure(&block)
    mod = Module.new
    fun_cache = Hash.new

    Util.singleton_class_of(mod).module_eval do
      define_method :compute do |root, opts|
        num_threads = (opts.is_a?(Hash) ? opts[:threads] : opts).to_i
        instance = Class.new { include mod }.new
        CompTree.build do |driver|
          # 'fun' definitions
          fun_cache.each_pair { |node_name, (child_names, fun_block)|
            driver.define(node_name, *child_names, &fun_block)
          }

          # 'def' definitions
          mod.ancestors.each { |ancestor|
            if defs = DefParser.defs[ancestor]
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
        fun_cache[node_name.to_sym] = [child_syms, fun_block]
      end

      define_method :method_added do |method_name|
        file, line = DefParser.file_line(caller)
        args = DefParser.parse(mod, method_name, file, line)
      end
    end

    mod.module_eval(&block)
    mod
  end
end

