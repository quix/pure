require 'pathname'
require 'tempfile'

here = Pathname(__FILE__).dirname
require here + "../spec/common"
require 'quix/ruby'
root = here + ".."
readme = root + "README"
lib = root + "lib"

describe readme do
  ["Synopsis"].each { |section|
    it "#{section} should run as claimed" do
      contents = readme.read

      code = %{
        $LOAD_PATH.unshift "#{lib.expand_path}"
        require 'rubygems'
      } + contents.match(%r!== #{section}.*?\n(.*?)^\S!m)[1]

      expected = code.scan(%r!\# => (.*?)\n!).flatten.join("\n")

      Tempfile.open("pure-readme") { |file|
        file.puts code
        file.close
        result = `"#{Quix::Ruby::EXECUTABLE}" "#{file.path}"`
        raise unless $?.exitstatus
        result.chomp.should == expected
      }
    end
  }
end
