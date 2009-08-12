require File.dirname(__FILE__) + '/pure_spec_base'

describe "pure" do
  describe "`def' definitions" do
    it "should be parsed with 1 arg default" do
      lambda {
        pure do
          def f(x = 99)
            x
          end
        end
      }.should raise_error(
        Pure::DefaultArgumentError,
        "cannot use default argument in pure function at #{__FILE__}:8"
      )
    end

    it "should be parsed with non-paren 1 arg" do
      pure do
        def f x
          x + 33
        end
      end.compute(3, :x => 44).f.should == 77
    end

    it "should be parsed with non-paren 1 arg splat" do
      lambda {
        pure do
          def f *x
            x + 33
          end
        end
      }.should raise_error(Pure::SplatError)
    end

    it "should be parsed with non-paren 2 arg splat" do
      lambda {
        pure do
          def f x, *y
            x + 33
          end
        end
      }.should raise_error(Pure::SplatError)
    end

    it "should be parsed with non-paren 2 args" do
      pure do
        def f x, y
          x + y
        end
      end.compute(3, :x => 33, :y => 44).f.should == 77
    end

    it "should be parsed with 2 arg default" do
      lambda {
        pure do
          def f(x, y = 99)
            x + y
          end
        end
      }.should raise_error(Pure::DefaultArgumentError)
    end

    it "should be parsed with non-paren 1 arg default" do
      lambda {
        pure do
          def f x = 99
            x + 44
          end
        end
      }.should raise_error(Pure::DefaultArgumentError)
    end

    it "should be parsed with non-paren 2 arg 1 default" do
      lambda {
        pure do
          def f x, y = 99
            x + y
          end
        end
      }.should raise_error(Pure::DefaultArgumentError)
    end

    it "should be parsed with non-paren 2 arg 2 default" do
      lambda {
        pure do
          def f x = 77, y = 99
            x + y
          end
        end
      }.should raise_error(Pure::DefaultArgumentError)
    end

    it "should ignore &block" do
      pure do
        def f(&block)
          33
        end
      end.compute(4).f.should == 33
    end

    it "should ignore &block with 1 arg" do
      pure do
        def f(x, &block)
          x + 44
        end
      end.compute(4, :x => 33).f.should == 77
    end

    it "should ignore &block with 2 arg" do
      pure do
        def f(x, y, &block)
          x + 44
        end
      end.compute(4, :x => 33, :y => nil).f.should == 77
    end

    it "should ignore &block with 1 arg default" do
      lambda {
        pure do
          def f(x = 11, &block)
            x + 44
          end
        end
      }.should raise_error(Pure::DefaultArgumentError)
    end

    it "should ignore no-paren &block" do
      pure do
        def f &block
          33
        end
      end.compute(4).f.should == 33
    end

    it "should ignore no-paren &block with 1 arg" do
      pure do
        def f x, &block
          x + 44
        end
      end.compute(4, :x => 33).f.should == 77
    end

    it "should ignore no-paren &block with 2 arg" do
      pure do
        def f x, y, &block
          x + 44
        end
      end.compute(4, :x => 33, :y => nil).f.should == 77
    end

    it "should ignore no-paren &block with 1 arg default" do
      lambda {
        pure do
          def f x = 11, &block
            x + 44
          end
        end
      }.should raise_error(Pure::DefaultArgumentError)
    end
    
    it "should have fun_name and arg_names" do
      pure do
        def f(x, y)
          [fun_name, arg_names, x + y]
        end
      end.compute(:x => 11, :y => 22).f.should == [:f, [:x, :y], 33]
    end

    it "should have fun_name and arg_names, given 1 arg" do
      pure do
        def f(x)
          [fun_name, arg_names, x]
        end
      end.compute(:x => 11).f.should == [:f, [:x], 11]
    end

    it "should have fun_name and arg_names, given no args" do
      pure do
        def f
          [fun_name, arg_names]
        end
      end.compute.f.should == [:f, []]
    end
  end
end
