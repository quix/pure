require File.dirname(__FILE__) + "/../spec/common"

describe "error checking:" do
  describe "two defs on the same line" do
    it "should raise error" do
      lambda {
        Module.new {
          include Pure
          def x ; end ; def y ; end
        }
      }.should raise_error(Pure::ParseError)
    end
  end

  describe "`fun'" do
    describe "given hash of size != 1" do
      it "should raise error" do
        lambda {
          Module.new {
            include Pure
            fun :x => 1, :y => 2 do
            end
          }
        }.should raise_error(ArgumentError)
      end
    end

    describe "given more than 1 argument" do
      it "should raise error" do
        lambda {
          Module.new {
            include Pure
            fun :x, :y do
            end
          }
        }.should raise_error(ArgumentError)
      end
    end
  end
end
