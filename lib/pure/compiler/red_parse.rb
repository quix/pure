#
# This file is self-contained, intended for use by an external server.
#
# It is not included by the top-level pure.rb.
#
 
require 'pure/version'
require 'pure/names'
require 'redparse'
 
module Pure
  module Compiler #:nodoc:
    class RedParse #:nodoc:
      #
      # Compiles and evaluates a function spec with arg values.
      #
      def evaluate_function(spec, *args)
        compile_function(spec).send(spec[:name], *args)
      end
 
      #
      # Compiles a function spec extracted by
      # Pure::Parser::RedParse.
      #
      # Returns an object which responds to spec[:name].
      #
      def compile_function(spec)
        code_data = (
          if spec[:origin] == :fun
            fun_to_define_method(spec[:name], spec[:code])
          else
            spec[:code]
          end
        )
 
        instance = Names.new(spec[:name], spec[:args])
        Thread.current[:pure_compiler_input] = code_data.unparse
 
        # use singleton to hide locals
        class << instance
          eval(Thread.current[:pure_compiler_input])
        end
 
        instance
      end
 
      #
      # Code-transform `fun' definitions into `define_method' definitions.
      #
      def fun_to_define_method(name, code_data)
        # it's unclear how to create a LiteralNode by hand
        literal_node = ::RedParse.new(":x").parse
        literal_node[0] = name

        code_data[1] = "define_method"
        code_data[2] = [literal_node]
        code_data
      end
    end
  end
end
 
