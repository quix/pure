
module Pure
  class Driver
    def initialize(worker_class, mod, num_parallel, overrides)
      @worker = worker_class.new
      @worker.define_function_begin(mod, num_parallel)
      @driver = CompTree.build do |driver|
        overrides.each_pair { |name, value|
          driver.define(name.to_sym) { value }
        }
        mod.each_function { |name, spec|
          if elems = spec[:elems]
            build_fun_map(driver, name, elems)
          end
          node = driver.nodes[name]
          unless node and node.function
            function = @worker.define_function(spec)
            driver.define(name, *spec[:args], &function)
          end
        }
        driver
      end
      @worker.define_function_end
    end

    def compute(root)
      @driver.compute(root, @worker.num_parallel)
    rescue CompTree::NoFunctionError => exception
      raise Pure::NoFunctionError.new(exception.node_name)
    end

    def each_function_name(&block)
      @driver.nodes.each_key(&block)
    end

    def build_fun_map(driver, name, elems)
      elems.each_with_index { |(elem_name, elem), i|
        driver.define(elem_name) { elem }
      }
    end
  end
end
