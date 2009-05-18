
module Pure
  module PurePrivate
    module Util
      module_function
    
      def singleton_class_of(obj)
        class << obj
          self
        end
      end
    end
  end
end
