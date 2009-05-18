
require 'pure/error'
require 'pure/pure_private/util'

# some silliness to fool rcov
have_ripper = (begin require 'ripper' ; rescue LoadError ; nil ; end) != nil
suffix = have_ripper ? "ripper" : "ruby_parser"
require "pure/pure_private/def_processor_#{suffix}"

module Pure
  module PurePrivate
    module DefParser
      @def_cache = Hash.new

      class << self
        def parse(mod, method_name, backtrace)
          file, line = file_line(backtrace)
          defs = @def_cache[file] || (
            @def_cache[file] = DefProcessor.new.run(File.read(file))
          )
          spec = defs[line]
          unless spec[:name] and spec[:name] == method_name
            raise PureError::ParseError,
            "failure parsing #{mod.name}##{method_name} at #{file}:#{line}" 
          end
          spec
        end

        def file_line(backtrace)
          file, line = backtrace.match(%r!\A(.*?):(\d+)!).captures
          return file, line.to_i
        end
      end
    end
  end
end
