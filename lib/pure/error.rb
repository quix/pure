
module Pure
  # Base class for Pure errors.
  class Error < StandardError
  end

  # No parser found.
  class NoParserError < Error
    def initialize  #:nodoc:
      super("no parser found")
    end
  end

  # A missing function was encountered during a computation.
  class NoFunctionError < Error
    attr_reader :function_name  #:nodoc:

    def initialize(function_name)  #:nodoc:
      @function_name = function_name
      super(custom_message)
    end

    def custom_message  #:nodoc:
      "no function named `#{function_name}'"
    end
  end
  
  # Base class for errors found during extraction.
  class ExtractionTimeError < Error
    attr_reader :file, :line  #:nodoc:

    def initialize(file, line)  #:nodoc:
      @file, @line = file, line
      super(custom_message + " at #{@file}:#{@line}")
    end
  end

  class ParseError < ExtractionTimeError
  end
  
  class ParseEntityError < ParseError
    attr_reader :entity
    
    def initialize(file, line, entity)
      @entity = entity
      super(file, line)
    end

    def custom_message
      "failed to parse `#{entity}'"
    end      
  end

  # The parser could not extract a method definition.
  class ParseMethodError < ParseEntityError
  end

  # Base class for breaches of pure function restrictions.
  class RestrictionError < ExtractionTimeError
  end

  # A *splat argument was present in a pure function defined with `def'.
  class SplatError < RestrictionError
    def custom_message  #:nodoc:
      "cannot use splat argument (*) in pure function defined with `def'"
    end
  end

  # A pure function had a default argument.
  class DefaultArgumentError < RestrictionError
    def custom_message  #:nodoc:
      "cannot use default argument in pure function"
    end
  end

  # +define_method+ called inside a pure module.
  class DefineMethodError < RestrictionError
    def custom_message  #:nodoc:
      "cannot use define_method in a pure module (use `fun' instead)"
    end
  end

  # Attempt to create a pure module inside +eval+.
  class EvalError < RestrictionError
    def custom_message  #:nodoc:
      "cannot define a pure module inside eval (write it to a file instead)"
    end
  end
end
