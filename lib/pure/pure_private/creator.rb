
require 'pure/pure_private/extractor'
require 'pure/pure_private/util'
require 'comp_tree'

module Pure
  module PurePrivate
    module Creator
      @method_database = Hash.new { |hash, key|
        hash[key] = Hash.new
      }
      
      class << self
        include Util
        
        attr_reader :method_database

        def build_and_compute(mod, method_database, root, num_threads, &block)
          CompTree.build do |driver|
            mod.ancestors.each { |ancestor|
              if defs = method_database[ancestor]
                defs.each_pair { |method_name, spec|
                  existing_node = driver.nodes[method_name]
                  if existing_node.nil? or existing_node.function.nil?
                    node = driver.define(method_name, *spec[:args])
                    node.function = yield method_name, spec
                  end
                }
              end
            }
            driver.compute(root, num_threads)
          end
        end

        def instance_compute(mod, root, opts)
          num_threads = (opts.is_a?(Hash) ? opts[:threads] : opts).to_i
          instance = Object.new.extend(mod)
          Creator.build_and_compute(mod, method_database, root, num_threads) {
            |method_name, spec|
            lambda { |*args|
              instance.send(method_name, *args)
            }
          }
        end

        def define_compute(mod, method_database)
          singleton_class_of(mod).module_eval do
            define_method :compute do |root, opts|
              Creator.instance_compute(mod, root, opts)
            end
          end
        end

        def define_fun(mod, fun_mod, method_database)
          singleton_class_of(mod).module_eval do
            define_method :fun do |*args, &block|
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
                  [child_names.to_sym]
                end
              )
              node_sym = node_name.to_sym
              fun_mod.module_eval {
                define_method(node_sym, &block)
              }
              spec = Extractor.extract(:__fun, caller)
              method_database[fun_mod][node_sym] = {
                :name => node_sym,
                :args => child_syms,
                :sexp => spec[:sexp],
              }
              nil
            end
          end
        end

        def define_method_added(mod, method_database)
          singleton_class_of(mod).module_eval do
            define_method :method_added do |method_name|
              method_database[mod][method_name] = (
                Extractor.extract(method_name, caller)
              )
            end
          end
        end

        def create(&block)
          mod = Module.new
          fun_mod = Module.new
          define_compute(mod, @method_database)
          define_fun(mod, fun_mod, @method_database)
          define_method_added(mod, @method_database)
          mod.module_eval(&block)
          mod.module_eval { include fun_mod }
          mod
        end
      end
    end
  end
end
