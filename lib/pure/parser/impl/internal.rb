
module Pure
  module Parser
    module Internal
      module_function

      def extract(mod, method_name, file, line)
        if method_name == :__fun
          Hash.new
        else
          parameters = mod.instance_method(method_name).parameters.reject {
            |type, name|
            type == :block
          }
          args = parameters.map { |type, name|
            name
          }
          types = parameters.inject(Hash.new) { |acc, (type, name)|
            acc.merge!(type => true)
          }
          {
            :name => method_name,
            :args => args,
            :splat => types[:rest],
            :default => types[:opt],
          }
        end.merge(:file => file, :line => line)
      end
    end
  end
end
