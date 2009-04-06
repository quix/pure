
require 'ruby_parser'
require 'sexp_processor'
    
module Pure
  class DefProcessor < SexpProcessor
    class << self
      def parse(string)
        RubyParser.new.parse(string)
      end
    end
    
    def initialize
      super()
      @defs = Hash.new
    end
        
    attr_reader :defs
        
    def process_defn(sexp)
      method_name = sexp[1]
      args = sexp[2].to_a[1..-1]
      @defs[sexp.line] = [method_name, *args]
      sexp.clear
    end
  end
end
