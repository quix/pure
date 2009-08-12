
module Pure
  module Util
    module_function
  
    def file_line(backtrace)
      file, line = backtrace.match(%r!\A(.*?):(\d+)!).captures
      return file, line.to_i
    end

    def to_camel_case(str)
      str.split('_').map { |t| t.capitalize }.join
    end
  end
end
