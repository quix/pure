$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"

require 'rubygems'
require 'pure'
require 'pathname'
require 'spec'

include Pure

AVAILABLE_ENGINES = Pure::PurePrivate::Extractor::DEFAULT_ENGINE_SEQUENCE.map {
  |engine|
  begin
    Pure.engine = engine
  rescue PurePrivate::NotImplementedError
    nil
  end
}.reject { |t| t.nil? }

module Spec::Example::ExampleGroupMethods
  alias_method :example__original, :example

  def example(*args, &block)
    AVAILABLE_ENGINES.each { |engine|
      describe "(#{engine})" do
        before :each do
          Pure.engine = engine
        end
        example__original(*args, &block)
      end
    }
  end

  [:it, :specify].each { |method_name|
    remove_method method_name
    alias_method method_name, :example
  }
end
