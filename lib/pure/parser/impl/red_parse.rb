
require 'pure/parser/impl/base_parser'

module Pure
  module Parser
    class RedParse
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
          end
        end
        
        def process_method_node(node)
          line = node.startline
          name = node[1].to_sym
          args = (
            if node[2].nil?
              []
            else
              node[2].map { |var| var.first.to_sym }
            end
          )
          @defs[line] = {
            :name => name,
            :args => args,
            :code => node,
            :splat => false,   # TODO: whether splat arg is present
            :default => false, # TODO: whether any default args are present
          }
        end
        
        # TODO: process 'fun' definitions
        def process_fun
        end
      end
    end
  end
end

