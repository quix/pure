
require 'pure/parser/impl/base_parser'

module Pure
  module Parser
    class RedParse
      class << self
        def extract(mod, method_name, file, line)
          BaseParser.extract(mod, method_name, file, line, Processor)
        end

        def compiler
          %w[pure/compiler/red_parse Pure::Compiler::RedParse]
        end
      end

      class Processor
        def initialize(file)
          @file = file
          @defs = Hash.new
        end
        
        def run
          process(::RedParse.new(File.read(@file)).parse)
          @defs
        end
        
        def process(node)
          process_callback(node)
          if node.is_a? Array
            node.each { |child|
              process(child)
            }
          end
        end
        
        def process_callback(node)
          case node
          when ::RedParse::MethodNode
            process_method_node(node)
          when ::RedParse::CallNode
            process_call_node(node)
          end
        end
        
        def process_method_node(node)
          line = node.startline
          name = node[1].to_sym
          splat, default = (
            if node[2].nil?
              [false, false]
            else
              [::RedParse::UnaryStarNode, ::RedParse::AssignNode].map { |klass|
                node[2].any? { |elem| elem.is_a? klass }
              }
            end
          )
          args = (
            if splat or default or node[2].nil?
              []
            else
              node[2].map { |elem|
                elem.first.to_sym
              }.reject { |elem|
                elem == :"&@"
              }
            end
          )
          @defs[line] = {
            :name => name,
            :args => args,
            :code => node,
            :splat => splat,
            :default => default,
          }
        end

        def process_call_node(node)
          if node[1] =~ %r!\Afun(_map)?\Z!
            process_fun(node)
          end
        end

        def process_fun(node)
          line = node.startline
          @defs[line] = {
            :name => :__fun,
            :code => node,
          }
        end
      end
    end
  end
end

