
require 'pure/error'

# some silliness to fool rcov
have_ripper = (begin require 'ripper' ; rescue LoadError ; nil ; end) != nil
suffix = have_ripper ? "ripper" : "ruby_parser"
require "pure/def_processor_#{suffix}"

module Pure
  module DefParser
    @def_cache = Hash.new
    @defs = Hash.new { |hash, key| hash[key] = Hash.new }
  
    class << self
      def [](mod)
        @defs[mod]
      end
  
      def rip(mod, method_name, file, line)
        unless @def_cache.has_key? file
          processor = DefProcessor.new
          processor.process(DefProcessor.parse(File.read(file)))
          @def_cache[file] = processor.defs
        end
        found_method_name, *args = @def_cache[file][line]
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
  
      def singleton_class_of(mod)
        class << mod
          self
        end
      end
    end
      
    def append_features(mod)
      method_added_orig = mod.method(:method_added)
      DefParser.singleton_class_of(mod).module_eval {
        define_method(:method_added) { |method_name|
          if method_added_orig
            method_added_orig.call(method_name)
          end
          file, line = DefParser.file_line(caller)
          args = DefParser.rip(mod, method_name, file, line)
        }
      }
    end
  end
end
