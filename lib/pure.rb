
require 'pure/pure_private/creator'
require 'pure/pure_private/extractor'

module Pure
  PURE_VERSION = "0.1.0"

  module_function

  def pure(&block)
    PurePrivate::Creator.create_module(&block)
  end

  class << self
    [:engine, :engine=].each { |name|
      define_method name, &PurePrivate::Extractor.method(name)
    }
  end
end
