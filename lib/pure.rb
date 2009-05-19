
require 'pure/pure_private/driver'
require 'pure/pure_private/extractor'

module Pure
  PURE_VERSION = "0.1.0"

  module_function

  def pure(&block)
    PurePrivate::Driver.define_module(&block)
  end

  class << self
    [:parser, :parser=].each { |name|
      define_method name, &PurePrivate::Extractor.method(name)
    }
  end
end
