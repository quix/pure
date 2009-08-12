require File.dirname(__FILE__) + '/pure_spec_base'

describe "compute" do
  describe "overrides" do
    it "should replace missing functions" do
      pure do
        def add(x, y)
          x + y
        end
      end.compute(4, :x => 33, :y => 44).add.should == 77
    end
  
    it "should fail if underspecified" do
      (1..4).each { |n|
        lambda {
          pure do
            def add(x, y)
              x + y
            end
          end.compute(n, :y => 44).add
        }.should raise_error(Pure::NoFunctionError, "no function named `x'")
      }
    end
  
    it "should override no-argument functions" do
      (1..4).each { |n|
        pure do
          def add(x, y)
            x + y
          end
          def x
            33
          end
          def y
            44
          end
        end.compute(n, :x => 55).add.should == 99
      }
    end
  
    it "should override multi-argument functions" do
      (1..4).each { |n|
        pure do
          def add(x, y)
            x + y
          end
          def x
            33
          end
          def y
            44
          end
        end.compute(n, :add => 11).add.should == 11
      }
    end

    it "should override a root function" do
      (1..4).each { |n|
        greet = pure do
          def hello(name)
            "Hello, #{name}."
          end
          
          def name
            "Bob"
          end
        end
        greet.compute(n).hello.should eql("Hello, Bob.")
        greet.compute(n, :name => "Ralph").hello.should eql("Hello, Ralph.")
        greet.compute(n, :hello => "Goodbye.").hello.should eql("Goodbye.")
      }
    end

    it "should prevent the overridden function from being called" do
      count = 0
      pure do
        def f x
          x + 44
        end

        fun :x do
          count += 1
          33
        end
      end.compute(:x => 11).f.should eql(55)
      count.should == 0
    end

    it "should convert non-symbol keys to symbols" do
      (1..4).each { |n|
        pure do
          def add(x, y)
            x + y
          end
        end.compute(n, "x" => 55, "y" => 44).add.should == 99
      }
    end
  end
end
