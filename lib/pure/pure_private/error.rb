
module Pure
  module PurePrivate
    class Error < StandardError
    end
    
    class NoFunctionError < Error
    end

    class ParseError < Error
    end

    class ArgumentError < Error
    end

    class SplatError < ParseError
      def initialize(line)
        super()
        @line = line
      end

      def message
        "cannot use splat (*) argument in a pure function at line #{@line}"
      end
    end

    class NotImplementedError < Error
    end
  end
end
