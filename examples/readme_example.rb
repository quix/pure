require 'pathname'
require 'tempfile'

here = Pathname(__FILE__).dirname
require here + "../spec/common"
require 'jumpstart/ruby'
root = here + ".."
readme = root + "README.rdoc"
lib = root + "lib"

describe readme do
  ["Synopsis"].each { |section|
    describe section do
      it "should run as claimed" do
        contents = readme.read
  
        code = %{
          $LOAD_PATH.unshift "#{lib.expand_path}"
          require 'rubygems'
        } + contents.match(%r!== #{section}.*?\n(.*?)^\S!m)[1]
  
        expected = code.scan(%r!\# => (.*?)\n!).flatten.join("\n")
  
        Tempfile.open("pure-readme") { |file|
          file.puts code
          file.close
          result = `"#{Jumpstart::Ruby::EXECUTABLE}" "#{file.path}"`
          raise unless $?.exitstatus
          result.chomp.should == expected
        }
      end
    end
  }
end
