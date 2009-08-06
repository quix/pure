
require 'pure/pure_private/error'
require 'pure/pure_private/util'

module Pure
  module PurePrivate
    module Extractor
      DEFAULT_ENGINE_SEQUENCE = [
        :parameters,
        :ripper,
        :ruby_parser,
      ]

      @engine = nil

      class << self
        include Util

        def extract(mod, method_name, backtrace)
          unless @engine
            @engine = default_engine
          end
          file, line = file_line(backtrace.first)
          @engine.extract(mod, method_name, file, line)
        end

        def engine=(engine)
          if engine.nil?
            @engine = nil
          else
            begin
              require "pure/pure_private/extractor/#{engine}_check"
              @engine = PurePrivate::Extractor.const_get(
                to_camel_case(engine.to_s)
              )
            rescue LoadError
              raise PurePrivate::NotImplementedError,
              "engine not available: #{engine}"
            end
          end
          engine
        end

        def engine
          if @engine
            @engine.
            name.
            split("::").
            last.
            gsub(%r![A-Z]!) { |capital| "_" + capital.downcase }[1..-1].
            to_sym
          end
        end

        def default_engine
          DEFAULT_ENGINE_SEQUENCE.each { |engine|
            begin
              self.engine = engine
              break
            rescue PurePrivate::NotImplementedError
              false # rcov workaround
            end
          }
          @engine or raise PurePrivate::Error, "no extractor engine available"
        end
      end
    end
  end
end
