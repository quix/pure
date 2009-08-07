
require 'pure/pure_private/creator'
require 'pure/pure_private/extractor'

module Pure
  module PurePrivate
    VERSION = "0.1.0"
  end

  module_function

  #
  # Create a <em>pure module</em>.  The given block is evaluated in
  # the context of the created module.
  #
  # A pure module is a regular Ruby module whose singleton class
  # includes PurePrivate::SingletonFeatures and whose methods are
  # specially registered for lexicographical analysis.
  # 
  # In this package's terminology, the methods of a pure module are
  # called <em>pure functions</em>.
  #
  def pure(&block)
    PurePrivate::Creator.create_module(&block)
  end

  class << self
    #
    # call-seq: engine
    #           engine=(value)
    #
    # Query/change the parse engine.  Available engines are:
    # * :parameters (ruby-1.9.2+ only)
    # * :ripper (ruby-1.9 only)
    # * :ruby_parser
    #
    # The default engine is tried in that order.
    #
    def engine  # for rdoc only
    end
    remove_method :engine

    [:engine, :engine=].each { |name|
      define_method name, &PurePrivate::Extractor.method(name)
    }
  end
end
