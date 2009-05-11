
require 'ripper'
  
module Pure
  class DefProcessor
    def initialize
      @defs = Hash.new
    end
    
    def run(code)
      process(Ripper.sexp(code))
      @defs
    end
    
    def process_def(sexp)
      method_name = sexp[1][1].to_sym
      line = sexp[1][2][0]
      params = (
        case sexp[2].first
        when :params
          sexp[2]
        when :paren
          sexp[2][1]
        else
          raise "unforeseen def syntax"
        end
      )
      args = (
        if params[1].nil?
          []
        else
          params[1].map { |t| t[1].to_sym }
        end
      )
      @defs[line] = [method_name, *args]
    end

    def process(sexp)
      if sexp.is_a?(Array)
        if sexp.first == :def
          process_def(sexp)
        else
          sexp.each { |sub_sexp|
            process(sub_sexp)
          }
        end
      end
    end
  end
end
