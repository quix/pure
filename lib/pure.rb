
require 'pure/pure_private/creator.rb'

module Pure
  PURE_VERSION = "0.1.0"

  module_function

  def pure(&block)
    PurePrivate::Creator.create(&block)
  end
end
