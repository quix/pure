
require 'pure/pure_private/error'

module Pure
  module PurePrivate
    module Extractor
      module Parameters
        module_function

        def extract(mod, method_name, file, line)
          if method_name == :__fun
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
end
