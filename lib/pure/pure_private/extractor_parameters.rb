
unless Method.instance_methods.include? :parameters
  raise LoadError
end
  
module Pure
  module PurePrivate
    module ExtractorParameters
      module_function

      def extract(mod, method_name, file, line)
        if method_name == :fun
          Hash.new
        else
          {
            :name => method_name,
            :args => mod.instance_method(method_name).parameters.map {
              |type, name|
              if type == :rest
                raise SplatError.new(file, line)
              end
              name
            },
          }
        end
      end
    end
  end
end
