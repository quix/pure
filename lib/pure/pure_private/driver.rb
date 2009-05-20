
require 'pure/pure_private/function_database'
require 'pure/pure_private/error'
require 'comp_tree'

module Pure
  module PurePrivate
    module Driver
      include FunctionDatabase

      module_function

      def build_and_compute(mod, root, num_threads, &block)
        begin
          CompTree.build do |driver|
            mod.ancestors.each { |ancestor|
              if defs = FUNCTION_DATABASE[ancestor]
                defs.each_pair { |function_name, spec|
                  existing_node = driver.nodes[function_name]
                  if existing_node.nil? or existing_node.function.nil?
                    final_spec = spec.merge(:module => ancestor)
                    node = driver.define(function_name, *spec[:args])
                    node.function = yield function_name, final_spec
                  end
                }
              end
            }
            driver.compute(root, num_threads)
          end
        rescue CompTree::NoFunctionError => exception
          raise PurePrivate::NoFunctionError, exception.message
        rescue CompTree::ArgumentError => exception
          raise PurePrivate::ArgumentError, exception.message
        end
      end

      def create_instance_and_compute(mod, root, opts)
        num_threads = (opts.is_a?(Hash) ? opts[:threads] : opts).to_i
        instance = Object.new.extend(mod)
        build_and_compute(mod, root, num_threads) { |function_name, spec|
          lambda { |*args|
            instance.send(function_name, *args)
          }
        }
      end
    end
  end
end
