
require 'pure/pure_private/pure_module_creator.rb'

module Pure
  PURE_VERSION = "0.1.0"

  module_function

  def pure(&block)
    PurePrivate::PureModuleCreator.create(&block)
  end
end
