
require 'pure/def_parser'
require 'pure/util'
require 'comp_tree'

module Pure
  @fun_cache = Hash.new

  class << self
    include DefParser

    attr_accessor :fun_cache

    def append_features(mod)
      unless @fun_cache.has_key? mod
        super
        @fun_cache[mod] = Hash.new
        Util.singleton_class_of(mod).module_eval do
          define_method :compute do |root, opts|
            num_threads = (opts.is_a?(Hash) ? opts[:threads] : opts).to_i
            instance = Class.new { include mod }.new
            CompTree.build do |driver|
              DefParser.defs[mod].each_pair { |method_name, args|
                driver.define(method_name, *args) { |*objs|
                  instance.send(method_name, *objs)
                }
              }
              Pure.fun_cache.each_pair { |node_name, (child_names, block)|
                driver.define(node_name, *child_names, &block)
              }
              driver.compute(root, num_threads)
            end
          end
  
          eval <<-eval_end
            def fun(*args, &block)
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
              Pure.fun_cache[node_name.to_sym] = [child_syms, block]
            end
          eval_end
        end
      end
    end
  end
end 

