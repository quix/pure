
require 'pure/pure_private/error'
require 'pure/pure_private/util'

module Pure
  module PurePrivate
    module Extractor
      HAS_METHOD_PARAMETERS = Method.instance_methods.include?(:parameters)

      DEFAULT_PARSER = (
        if HAS_METHOD_PARAMETERS
          nil
        elsif RUBY_VERSION >= "1.9"
          "ripper"
        else
          "ruby_parser"
        end
      )

      @parser = nil
      @engine = nil
      @cache = Hash.new { |hash, key| hash[key] = Hash.new }

      class << self
        include Util

        def extract(mod, method_name, backtrace)
          file, line = file_line(backtrace.first)
          if @parser.nil? and HAS_METHOD_PARAMETERS
            if method_name == :fun
              Hash.new
            else
              {
                :name => method_name,
                :args => mod.instance_method(method_name).parameters.map {
                  |type, name|
                  raise SplatError.new(file, line) if type == :rest
                  name
                },
              }
            end
          else
            if @parser.nil?
              self.parser = DEFAULT_PARSER
            end
            defs = @cache[@parser][file] || (
              @cache[@parser][file] = @engine.new(file).run
            )
            spec = defs[line]
            unless spec and spec[:name] and spec[:name] == method_name
              raise PurePrivate::ParseError,
              "failure parsing `#{method_name}' at #{file}:#{line}" 
            end
            spec.merge(:file => file, :line => line)
          end
        end

        def parser=(parser_name)
          if parser_name.nil?
            @engine = nil
          else
            require parser_name
            begin
              engine_name = "extractor_#{parser_name}"
              require "pure/pure_private/#{engine_name}"
              @engine = PurePrivate.const_get(to_camel_case(engine_name))
            rescue LoadError
              raise PurePrivate::NotImplementedError,
              "parser not supported: #{parser_name}"
            end
          end
          @parser = parser_name
        end

        attr_reader :parser
      end
    end
  end
end
