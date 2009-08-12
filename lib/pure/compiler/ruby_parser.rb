#
# This file is self-contained, intended for use by an external server.
#
# It is not included by the top-level pure.rb.
#

require 'pure/version'
require 'pure/names'
require 'ruby2ruby'

module Pure
  module Compiler  #:nodoc:
    class RubyParser  #:nodoc:
      def initialize
        @ruby2ruby = Ruby2Ruby.new
      end

      #
      # Compiles and evaluates a function spec with arg values.
      #
      def evaluate_function(spec, *args)
        compile_function(spec).send(spec[:name], *args)
      end

      #
      # Compiles a function spec extracted by
      # Pure::Parser::RubyParser.
      #
      # Returns an object which responds to spec[:name].
      #
      def compile_function(spec)
        sexp = (
          if spec[:origin] == :fun
            fun_to_define_method(spec[:name], spec[:code])
          else
            spec[:code]
          end
        )

        instance = Names.new(spec[:name], spec[:args])
        Thread.current[:pure_compiler_input] = @ruby2ruby.process(sexp)

        # use singleton to hide locals
        class << instance
          eval(Thread.current[:pure_compiler_input])
        end

        instance
      end

      #
      # Code-transform `fun' definitions into `define_method' definitions.
      #
      def fun_to_define_method(name, sexp)
        s(:iter,
          s(:call, nil, :define_method, s(:arglist, s(:lit, name.to_sym))),
          sexp[2],
          sexp[3]
        )
      end
    end
  end
end
