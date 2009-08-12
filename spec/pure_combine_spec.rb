require File.dirname(__FILE__) + '/pure_spec_base'

# factor out due to parsers changing
module PureCombineSpec
  module_function

  def create_mod_a
    pure do
      def area(width, height)
        width*height
      end
      
      def border
        5
      end
    end
  end

  def create_mod_b
    pure do
      def width(border)
        20 + border
      end
      
      def height(border)
        30 + border
      end
    end
  end
  
  def create_combined
    mod_a = create_mod_a
    mod_b = create_mod_b
    pure do
      include mod_a
      include mod_b
    end
  end
end
  
describe "pure" do
  describe "modules combined with other pure modules" do
    max_threads = 5

    it "should work with modules included into empty module" do
      combined = PureCombineSpec.create_combined
      (1..max_threads).each { |n|
        combined.compute(n).area.should == (20 + 5)*(30 + 5)  
      }
    end

    it "should work with modules included into overriding module" do
      combined = PureCombineSpec.create_combined
      combined_override = pure do
        include combined
        def border
          99
        end
      end
      (1..max_threads).each { |n|
        combined_override.compute(n).area.should == (20 + 99)*(30 + 99)  
      }
    end

    it "should work with one module included into another" do
      mod_a = PureCombineSpec.create_mod_a
      mod_b = PureCombineSpec.create_mod_b
      mod_a.module_eval do
        include mod_b
      end
      (1..max_threads).each { |n|
        mod_a.compute(n).area.should == (20 + 5)*(30 + 5)  
      }
    end
  end
end

