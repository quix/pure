
require 'ruby_parser'
require 'sexp_processor'
    
module Pure
  module PurePrivate
    class ExtractorProcessor < SexpProcessor
      def initialize
        super()
        @defs = Hash.new
      end
        
      def run(code)
        process(RubyParser.new.parse(code))
        @defs
      end
        
      def process(sexp)
        if sexp[0] == :defn
          name = sexp[1]
          args = sexp[2].to_a[1..-1]
          @defs[sexp.line] = {
            :name => name,
            :args => args,
            :sexp => sexp.dup,
          }
          sexp.clear
        elsif sexp[0] == :iter and
            sexp[1][0] == :call and
            sexp[1][1] == nil and
            sexp[1][2] == :fun
          @defs[sexp[1].line] = {
            :name => :__fun,
            :sexp => sexp.dup,
          }
          sexp.clear
        else
          super
        end
      end
    end
  end
end
