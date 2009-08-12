
module Pure
  class << self
    #
    # Create a <em>pure module</em>.  The given block is evaluated in
    # the context of the created module.
    #
    # A pure module is a Module instance whose methods have been
    # specially registered for lexical analysis.
    # 
    # The methods of a pure module are referred to as <em>pure
    # functions</em>.
    #
    # See Pure::PureModule.
    #
    def define(parser = Pure.parser, &block)
      PureModule.new(parser, &block)
    end

    attr_accessor :parser, :worker

    remove_method :parser
    def parser  #:nodoc:
      @parser ||= BundledParsers.find_default
    end

    remove_method :worker
    def worker  #:nodoc:
      @worker ||= NativeWorker
    end
  end
end
