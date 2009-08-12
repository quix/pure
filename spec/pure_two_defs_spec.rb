require File.dirname(__FILE__) + '/pure_spec_base'

describe "pure" do
  describe "with two defs on the same line" do
    it "should raise error unless Pure::Parser::Internal is used" do
      code = lambda {
        pure do
          def x ; end ; def y ; end
        end
      }
      if Pure.parser.name == "Pure::Parser::Internal"
        code.should_not raise_error
      else
        code.should raise_error(
          Pure::ParseMethodError, "failed to parse `x' at #{__FILE__}:8"
        )
      end
    end
  end
end
