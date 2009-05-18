
require 'ripper'
  
module Pure
  module PurePrivate
    class ExtractorProcessor
      def initialize
        @defs = Hash.new
      end

      def run(code)
        process(Ripper.sexp(code))
        @defs
      end

      def process_def(sexp)
        if sexp[0] == :def
          name = sexp[1][1].to_sym
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
          @defs[line] = {
            :name => name,
            :args => args,
            :sexp => sexp,
          }
          true
        else
          false
        end
      end

      def process_fun(sexp)
        if sexp[0] == :method_add_block and sexp[1].is_a?(Array)
          line = (
            if sexp[1][0] == :command and
                sexp[1][1].is_a?(Array) and
                sexp[1][1][1] == "fun"
              sexp[1][1][2][0]
            elsif sexp[1][0] == :method_add_arg and
                sexp[1][1].is_a?(Array) and
                sexp[1][1][0] == :fcall and
                sexp[1][1][1].is_a?(Array) and
                sexp[1][1][1][1] == "fun"
              sexp[1][1][1][2][0]
            else
              nil
            end
          )
          if line
            @defs[line] = {
              :name => :__fun,
              :sexp => sexp[2],
            }
            true
          else
            false
          end
        else
          false
        end
      end

      def process(sexp)
        if sexp.is_a? Array
          process_def(sexp) or process_fun(sexp) or (
            sexp.each { |sub_sexp|
              process(sub_sexp)
            }
          )
        end
      end
    end
  end
end
