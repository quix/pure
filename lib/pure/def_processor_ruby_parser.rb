
require 'ruby_parser'
require 'sexp_processor'
    
module Pure
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
      method_name = sexp[1]
      args = sexp[2].to_a[1..-1]
      @defs[sexp.line] = [method_name, *args]
      sexp.clear
    end
  end
end
