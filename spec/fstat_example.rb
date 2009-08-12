require File.dirname(__FILE__) + '/pure_spec_base'

describe "fstat example" do
  it "should succeed" do
    files = Dir["*"]
      
    stats = pure do
      files.each { |file|
        fun file do
          File.stat(fun_name.to_s)
        end
      }
      
      fun :total_size => files do |*values|
        values.inject(0) { |acc, stat| acc + stat.size }
      end
    end
    
    stats.compute { |result|
      result["Rakefile"].size.should eql(File.stat("Rakefile").size)
      total = files.inject(0) { |acc, file| acc + File.stat(file).size }
      result.total_size.should == total
    }
  end
end

