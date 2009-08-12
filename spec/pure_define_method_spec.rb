require File.dirname(__FILE__) + '/pure_spec_base'

describe "pure" do
  it "should raise error when define_method called" do
    lambda {
      pure do
        define_method :area do |width, height|
          width*height
        end
        
        def width
          5
        end
        
        def height
          7
        end
      end.compute :area, 3
    }.should raise_error(
      Pure::DefineMethodError,
      %r!cannot use define_method.* at #{__FILE__}:7!
    )
  end
end
