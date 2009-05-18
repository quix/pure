
require 'ruby_parser'
require 'sexp_processor'
    
module Pure
  module PurePrivate
    class DefProcessor < SexpProcessor
      def initialize
        super()
        @defs = Hash.new
      end
        
      def run(code)
        process(RubyParser.new.parse(code))
        @defs
      end
        
      def process_defn(sexp)
        name = sexp[1]
        args = sexp[2].to_a[1..-1]
        @defs[sexp.line] = {
          :name => name,
          :args => args,
          :sexp => sexp.dup,
        }
        sexp.clear
      end
    end
  end
end
