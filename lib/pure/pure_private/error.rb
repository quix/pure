
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

    class NotImplementedError < Error
    end
  end
end
