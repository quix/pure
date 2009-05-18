
require 'pure/pure_private/error'
require 'pure/pure_private/util'

# some silliness to fool rcov
have_ripper = (begin require 'ripper' ; rescue LoadError ; nil ; end) != nil
suffix = have_ripper ? "ripper" : "ruby_parser"
require "pure/pure_private/extractor_processor_#{suffix}"

module Pure
  module PurePrivate
    module Extractor
      @cache = Hash.new

      class << self
        include Util

        def extract(method_name, backtrace)
          file, line = file_line(backtrace.first)
          defs = @cache[file] || (
            @cache[file] = ExtractorProcessor.new.run(File.read(file))
          )
          spec = defs[line]
          unless spec[:name] and spec[:name] == method_name
            raise PurePrivate::Error::ParseError,
            "failure parsing #{method_name} at #{file}:#{line}" 
          end
          spec
        end
      end
    end
  end
end
