
require 'pure/pure_private/error'
require 'pure/pure_private/util'

module Pure
  module PurePrivate
    module ExtractorParser
      @cache = Hash.new { |hash, key| hash[key] = Hash.new }

      class << self
        def extract(mod, method_name, file, line, processor)
          defs = @cache[processor][file] || (
            @cache[processor][file] = processor.new(file).run
          )
          spec = defs[line]
          unless spec and spec[:name] and spec[:name] == method_name
            raise PurePrivate::ParseError,
            "failure parsing `#{method_name}' at #{file}:#{line}" 
          end
          spec.merge(:file => file, :line => line)
        end
      end
    end
  end
end
