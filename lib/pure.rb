
require 'pure/def_parser'
require 'pure/util'
require 'comp_tree'

module Pure
  @registered_modules = Hash.new

  class << self
    include DefParser

    def append_features(mod)
      unless @registered_modules[mod]
        super
        fun_cache = Hash.new
        Util.singleton_class_of(mod).module_eval do
          define_method :compute do |root, *opts|
            num_threads = (!opts.empty? && opts.first[:threads]) || 1
            instance = Class.new { include mod }.new
            CompTree.build { |driver|
              DefParser.defs[mod].each_pair { |method_name, args|
                driver.define(method_name, *args) { |*objs|
                  instance.send(method_name, *objs)
                }
              }
              fun_cache.each_pair { |node_name, (child_names, block)|
                driver.define(node_name, *child_names, &block)
              }
              driver.compute(root, num_threads)
            }
          end
  
          define_method :fun do |*args, &block|
            node_name, child_names = (
              if args.size == 1
                arg = args.first
                if arg.is_a? Hash
                  unless arg.size == 1
                    raise ArgumentError, "`fun' given hash of size != 1"
                  end
                  arg.first
                else
                  [arg.to_sym, []]
                end
              else
                raise ArgumentError,
                "wrong number of arguments (#{args.size} for 1)"
              end
            )
            fun_cache[node_name] = [child_names, block]
          end
        end
        @registered_modules[mod] = true
      end
    end
  end
end 

