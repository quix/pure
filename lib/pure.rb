
require 'pure/pure_private/driver'

module Pure
  PURE_VERSION = "0.1.0"

  module_function

  def pure(&block)
    PurePrivate::Driver.define_module(&block)
  end
end
