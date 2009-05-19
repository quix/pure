$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"

require 'rubygems'
require 'pure'
require 'pathname'
require 'spec'

include Pure

AVAILABLE_PARSERS = ["ruby_parser"] + (
  begin
    require 'ripper'
    ["ripper"]
  rescue LoadError
    []
  end
)

module Spec::Example::ExampleGroupMethods
  alias_method :example__original, :example

  def example(*args, &block)
    AVAILABLE_PARSERS.each { |parser|
      describe "(#{parser})" do
        before :each do
          Pure.parser = parser
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
