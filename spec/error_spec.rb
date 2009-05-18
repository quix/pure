require File.dirname(__FILE__) + "/common"

describe "error checking:" do
  describe "two defs on the same line" do
    it "should raise error" do
      lambda {
        pure do
          def x ; end ; def y ; end
        end
      }.should raise_error(Pure::PurePrivate::Error::ParseError)
    end
  end

  describe "`fun'" do
    describe "given hash of size != 1" do
      it "should raise error" do
        lambda {
          pure do
            fun :x => 1, :y => 2 do
            end
          end
        }.should raise_error(ArgumentError)
      end
    end

    describe "given more than 1 argument" do
      it "should raise error" do
        lambda {
          pure do
            fun :x, :y do
            end
          end
        }.should raise_error(ArgumentError)
      end
    end
  end
end
