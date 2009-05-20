
require 'pure/pure_private/error'
require 'pure/pure_private/util'

module Pure
  module PurePrivate
    module Extractor
      DEFAULT_PARSER = RUBY_VERSION >= "1.9.0" ? "ripper" : "ruby_parser"

      @cache = Hash.new
      @engine = nil

      class << self
        include Util

        def extract(method_name, backtrace)
          unless @engine
            self.parser = DEFAULT_PARSER
          end
          file, line = file_line(backtrace.first)
          defs = @cache[file] || (
            @cache[file] = @engine.new.run(File.read(file))
          )
          spec = defs[line]
          unless spec[:name] and spec[:name] == method_name
            raise PurePrivate::ParseError,
            "failure parsing #{method_name} at #{file}:#{line}" 
          end
          spec
        end

        def parser=(parser_name)
          require parser_name
          begin
            engine_name = "extractor_#{parser_name}"
            require "pure/pure_private/#{engine_name}"
            @engine = PurePrivate.const_get(to_camel_case(engine_name))
          rescue LoadError
            raise PurePrivate::NotImplementedError,
            "parser not supported: #{parser_name}"
          end
          @parser = parser_name
        end

        attr_reader :parser
      end
    end
  end
end
