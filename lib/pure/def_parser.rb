
require 'pure/error'
require 'pure/util'

# some silliness to fool rcov
have_ripper = (begin require 'ripper' ; rescue LoadError ; nil ; end) != nil
suffix = have_ripper ? "ripper" : "ruby_parser"
require "pure/def_processor_#{suffix}"

module Pure
  module DefParser
    @def_cache = Hash.new
    @defs = Hash.new { |hash, key| hash[key] = Hash.new }
  
    class << self
      attr_accessor :defs
  
      def parse(mod, method_name, file, line)
        def_cache_file = @def_cache[file] || (
          @def_cache[file] = DefProcessor.new.run(File.read(file))
        )
        found_method_name, *args = def_cache_file[line]
        unless found_method_name and method_name == found_method_name
          raise ParseError,
          "failure parsing #{mod.name}##{method_name} at #{file}:#{line}" 
        end
        @defs[mod][method_name] = args
      end
  
      def file_line(backtrace)
        file, line_s = backtrace.first.match(%r!\A(.*?):(\d+)!).captures
        return file, line_s.to_i
      end
    end
      
    def append_features(mod)
      method_added_orig = mod.method(:method_added)
      Util.singleton_class_of(mod).module_eval {
        define_method(:method_added) { |method_name|
          if method_added_orig
            method_added_orig.call(method_name)
          end
          file, line = DefParser.file_line(caller)
          args = DefParser.parse(mod, method_name, file, line)
        }
      }
    end
  end
end
