
module Pure
  module Extractor
    module_function

    def extract(mod, method_name, backtrace)
      file, line = Util.file_line(backtrace.first)
      if file == "(eval)"
        eval_error(backtrace)
      end
      mod.parser.extract(mod, method_name, file, line)
    end

    def eval_error(backtrace)
      backtrace.each_with_index { |desc, index|
        if desc =~ %r!:in \`eval\'\Z!
          file, line = Util.file_line(backtrace[index + 1])
          raise EvalError.new(file, line)
        end
      }
    end

    def record_function(mod, origin, name, args, backtrace)  #:nodoc:
      spec = ExtractedFunctions[mod.parser][mod][name] = (
        case origin
        when :def
          #
          # For `def' definitions, function and argument names are
          # determined at parse-time.
          #
          extract(mod, name, backtrace)
        when :fun
          #
          # For `fun' definitions, function and argument names are
          # determined at run-time.
          #
          # Use the __fun flag to verify the parser's discovery of a
          # `fun' call.
          #
          extract(mod, :__fun, backtrace).merge(:name => name, :args => args)
        end
      ).merge(
        :origin => origin,
        :parser => mod.parser.name
      )

      if origin == :def and spec[:splat]
        raise SplatError.new(spec[:file], spec[:line])
      end

      if spec[:default]
        raise DefaultArgumentError.new(spec[:file], spec[:line])
      end

      spec
    end
  end
end
