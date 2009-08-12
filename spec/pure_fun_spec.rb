require File.dirname(__FILE__) + '/pure_spec_base'

require 'jumpstart'

describe "pure" do
  describe "`fun' definitions" do
    it "should work with symbols" do
      pure do
        fun :area => [:width, :height] do |w, h|
          w*h
        end
        
        fun :width => [:border] do |b|
          20 + b
        end
        
        fun :height => :border do |b|
          30 + b
        end
        
        fun :border do
          5
        end
      end.compute(4).area.should == (20 + 5)*(30 + 5)
    end

    it "should work with symbols and parens" do
      pure do
        fun(:area => [:width, :height]) do |w, h|
          w*h
        end
        
        fun(:width => [:border]) do |b|
          20 + b
        end
        
        fun(:height => :border) do |b|
          30 + b
        end
        
        fun(:border) do
          5
        end
      end.compute(4).area.should == (20 + 5)*(30 + 5)
    end

    it "should work with mixed symbols and strings" do
      pure do
        fun :area => [:width, "height"] do |w, h|
          w*h
        end
        
        fun "width" => [:border] do |b|
          20 + b
        end
        
        fun :height => "border" do |b|
          30 + b
        end
        
        fun :border do
          5
        end
      end.compute(4).area.should == (20 + 5)*(30 + 5)
    end

    it "should work with `def' definitions" do
      pure do
        fun :width do
          33
        end
        
        def height
          44
        end

        fun :area => [:width, :height] do |w, h|
          w*h
        end
      end.compute(3).area.should == 33*44
    end

    it "should be overwritten by later `def' definitions" do
      Jumpstart::Ruby.no_warnings {
        pure do
          fun :f do
            44
          end
          
          def f
            33
          end
        end.compute(10).f.should == 33
      }
    end

    it "should overwrite earlier `def' definitions" do
      Jumpstart::Ruby.no_warnings {
        pure do
          def f
            33
          end

          fun :f do
            44
          end
        end.compute(10).f.should == 44
      }
    end

    it "should support splat in block args" do
      pure do
        fun :area => [:width, :height] do |*a|
          a[0]*a[1]
        end
        
        def width
          3
        end
        
        def height
          4
        end
      end.compute(3).area.should == 12
    end

    it "should support splat with single-element array" do
      pure do
        name = [:f]
        fun(*name) do
          33
        end
      end.compute(3).f.should == 33
    end

    it "should not preclude `def' definitions called `fun'" do
      pure do
        def misery(fun)
          fun**2
        end

        def fun(a, b)
          a + b
        end

        def a
          3
        end

        def b
          5
        end
      end.compute(3).misery.should == 64
    end

    it "should raise error when given hash of size != 1" do
      lambda {
        pure do
          fun :x => 1, :y => 2 do
          end
        end
      }.should raise_error(ArgumentError)
    end

    it "should raise error given more than 1 argument" do
      lambda {
        pure do
          fun :x, :y do
          end
        end
      }.should raise_error(ArgumentError)
    end

    it "should raise error with &block unless Pure::Parser::Internal is used" do
      code = lambda {
        pure do
          fun :f, &lambda { 33 }
        end.compute(4).f.should == 33
      }
      if Pure.parser.name == "Pure::Parser::Internal"
        code.should_not raise_error
      else
          code.should raise_error(Pure::ParseError)
      end
      
      code = lambda {
        pure do
          t = lambda { 33 }
          fun :f, &t
        end.compute(4).f.should == 33
      }
      if Pure.parser.name == "Pure::Parser::Internal"
        code.should_not raise_error
      else
        code.should raise_error(Pure::ParseError)
      end
    end

    it "should allow function names containing any characters" do
      %w[- / ? : ; . ! [ ] ( )].each { |char|
        pure do
          fun "f#{char}f" do
            33
          end
        end.compute[:"f#{char}f"].should == 33
      }
    end

    it "should have fun_name and arg_names, given multiple args" do
      pure do
        fun :f => [:x, :y] do |x, y|
          [fun_name, arg_names, x + y]
        end
      end.compute(:x => 11, :y => 22).f.should == [:f, [:x, :y], 33]
    end

    it "should have fun_name and fun_args, given 1 arg" do
      pure do
        fun :f => :x do |x|
          [fun_name, arg_names, x]
        end
      end.compute(:x => 11).f.should == [:f, [:x], 11]
    end

    it "should have fun_name and fun_args, given no args" do
      pure do
        fun :f do
          [fun_name, arg_names]
        end
      end.compute.f.should == [:f, []]
    end

    it "should not see internals of the compiler" do
      lambda {
        pure do
          fun :f do
            spec
          end
        end.compute.f
      }.should raise_error(NameError)
    end
  end
end
