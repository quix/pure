require File.dirname(__FILE__) + '/pure_spec_base'

describe "fstat example" do
  it "should succeed with manual style" do
    files = Dir["*"]
      
    file_stats = pure do
      files.each { |file|
        fun file do
          File.stat(fun_name.to_s)
        end
      }
      
      fun :total_size => files do |*stats|
        stats.inject(0) { |acc, stat| acc + stat.size }
      end
    end
    
    file_stats.compute(3) { |result|
      result["Rakefile"].size.should eql(File.stat("Rakefile").size)
      total = files.inject(0) { |acc, file| acc + File.stat(file).size }
      result.total_size.should == total
    }
  end

  it "should succeed with fun_map" do
    file_stats = pure do
      fun_map :stats_array => Dir["*"] do |file|
        [file, File.stat(file)]
      end

      fun :stats => :stats_array do |array|
        array.inject(Hash.new) { |acc, (name, value)|
          acc.merge!(name => value)
        }
      end

      def total_size(stats)
        stats.values.inject(0) { |acc, stat| acc + stat.size }
      end
    end

    file_stats.compute(3) { |result|
      result.stats["Rakefile"].size.should eql(File.stat("Rakefile").size)
      total = Dir["*"].inject(0) { |acc, file| acc + File.stat(file).size }
      result.total_size.should == total
    }
  end
end
