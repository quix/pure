
require 'pure/def_parser'
require 'comp_tree'

module Pure
  class << self
    include DefParser
    def append_features(mod)
      super
      fun_cache = Hash.new
      DefParser.singleton_class_of(mod).module_eval {
        define_method :compute do |root, *opts|
          num_threads = (!opts.empty? && opts.first[:threads]) || 1
          instance = Class.new { include mod }.new
          CompTree.build do |driver|
            DefParser[mod].each_pair { |method_name, args|
              driver.define(method_name, *args) { |*objs|
                instance.send(method_name, *objs)
              }
            }
            fun_cache.each_pair { |node_name, (child_names, block)|
              driver.define(node_name, *child_names, &block)
            }
            driver.compute(root, num_threads)
          end
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
      }
    end
  end
end 

