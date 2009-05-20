
require 'pure/pure_private/util'
require 'pure/pure_private/singleton_features'

module Pure
  module PurePrivate
    module Creator
      class << self
        include Util

        def create_module(&block)
          mod = Module.new
          fun_mod = Module.new
          singleton_class_of(mod).module_eval {
            include SingletonFeatures
            @fun_mod = fun_mod
          }
          mod.module_eval(&block)
          mod.module_eval {
            include fun_mod
          }
          mod
        end
      end
    end
  end
end
