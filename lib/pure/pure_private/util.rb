
module Pure
  module PurePrivate
    module Util
      module_function
    
      def file_line(backtrace)
        file, line = backtrace.match(%r!\A(.*?):(\d+)!).captures
        return file, line.to_i
      end

      def singleton_class_of(obj)
        class << obj
          self
        end
      end
    end
  end
end
