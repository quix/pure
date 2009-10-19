
require 'ruby_parser'
require 'sexp_processor'
require 'pure/parser/impl/base_parser'
    
module Pure
  module Parser
    module RubyParser
      class << self
        def extract(mod, method_name, file, line)
          BaseParser.extract(mod, method_name, file, line, Processor)
        end

        def compiler
          %w[pure/compiler/ruby_parser Pure::Compiler::RubyParser]
        end
      end

      module DupSexp
        module_function
        def dup_sexp(sexp)
          if sexp.is_a? Sexp or sexp.is_a? Array
            array = sexp.map { |sub_sexp|
              dup_sexp(sub_sexp)
            }
            Sexp.new.replace(array)
          else
            sexp
          end
        end
      end

      class Processor < SexpProcessor
        include DupSexp

        def initialize(file)
          super()
          @file = file
          @defs = Hash.new
        end
        
        def run
          process(::RubyParser.new.parse(File.read(@file)))
          @defs
        end

        def process(sexp)
          if sexp[0] == :defn
            name = sexp[1]
            args = dup_sexp(sexp[2][1..-1]).to_a
            args.reject! { |a| a.to_s =~ %r!\A&! }
            default = (
              args.last and args.last.is_a?(Array) and args.last[0] == :block
            )
            splat = args.any? { |arg| arg.to_s =~ %r!\A\*! }
            @defs[sexp.line] = {
              :name => name,
              :args => args,
              :code => dup_sexp(sexp),
              :splat => splat,
              :default => default,
            }
          elsif sexp[0] == :iter and
              sexp[1][0] == :call and
              sexp[1][1] == nil and
              sexp[1][2] == :fun
            @defs[sexp[1].line] = {
              :name => :__fun,
              :code => dup_sexp(sexp)
            }
          end
          super
        end
      end
    end
  end
end
