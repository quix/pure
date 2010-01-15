require File.dirname(__FILE__) + '/pure_spec_base'

require 'pure/parser/red_parse'
require 'pure/compiler/red_parse'

describe Pure::Compiler::RedParse do
  before :all do
    @compiler = Pure::Compiler::RedParse.new
  end

  it "should transform `fun' definitions to `define_method' definitions" do
    def_f = pure(Pure::Parser::RedParse) do
      def f(x, y)
        x + y
      end
    end
    
    fun_f = pure(Pure::Parser::RedParse) do
      fun :f => [:x, :y] do |a, b|
        a + b
      end
    end

    def_g = pure(Pure::Parser::RedParse) do
      def g
      end
    end

    fun_g = pure(Pure::Parser::RedParse) do
      fun :g do
      end
    end

    def_h = pure(Pure::Parser::RedParse) do
      def h(x)
        x**2
      end
    end

    fun_h = pure(Pure::Parser::RedParse) do
      fun :h => :x do |a|
        a**2
      end
    end

    fun_i = pure(Pure::Parser::RedParse) do
      fun :i => [:p, :q] do |*s|
        s.size
      end
    end

    fun_j = pure(Pure::Parser::RedParse) do
      fun :j => [:p, :q] do |r, *s|
        r + s
      end
    end

    [
      [:def, def_f, :f, "def f(x,y)\nx+y;\nend"],
      [:fun, fun_f, :f, "define_method :f do |a, b|\na+b\nend"],
      [:def, def_g, :g, "def g\n;\nend"],
      [:fun, fun_g, :g, "define_method :g do \nend"],
      [:def, def_h, :h, "def h(x)\nx**2;\nend"],
      [:fun, fun_h, :h, "define_method :h do |a|\na**2\nend"],
      [:fun, fun_i, :i, "define_method :i do |*s|\ns.size\nend"],
      [:fun, fun_j, :j, "define_method :j do |r, *s|\nr+s\nend"],
    ].each { |type, mod, name, expected|
      entry = Pure::ExtractedFunctions[Pure::Parser::RedParse][mod][name]
      entry[:code].should be_a(RedParse::Node)
      code_data = Marshal.load(Marshal.dump(entry[:code]))
      if entry[:origin] == :fun
        code_data = @compiler.fun_to_define_method(entry[:name], code_data)
      end
      recovered = (
        code_data.
        unparse.
        gsub(%r!\n+!, "\n").
        gsub(%r!^ +!, "").
        gsub(%r! +!, " ")
      )
      recovered.should == expected
    }
  end
end

