
require 'ripper'
require 'pure/parser/impl/base_parser'

module Pure
  module Parser
    module Ripper
      class << self
        def extract(mod, method_name, file, line)
          BaseParser.extract(mod, method_name, file, line, Processor)
        end
      end

      class Processor
        def initialize(file)
          @file = file
          @defs = Hash.new
        end

        def run
          process(::Ripper.sexp(File.read(@file)))
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
              #else
              #  raise ParseError.new(@file, line, "unforeseen `def' syntax"
              end
            )
            args = (
              if params[1].nil?
                []
              else
                params[1].map { |t| t[1].to_sym }
              end
            )
            splat = params.any? { |t| t.is_a?(Array) and t[0] == :rest_param }
            default = !!params[2]
            @defs[line] = {
              :name => name,
              :args => args,
              :code => sexp,
              :splat => splat,
              :default => default,
            }
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
                :code => sexp[2],
              }
            end
          end
        end

        def process(sexp)
          if sexp.is_a? Array
            process_def(sexp)
            process_fun(sexp)
            sexp.each { |sub_sexp|
              process(sub_sexp)
            }
          end
        end
      end
    end
  end
end
