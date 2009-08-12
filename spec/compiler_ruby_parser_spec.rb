require File.dirname(__FILE__) + '/pure_spec_base'

require 'pure/parser/ruby_parser'
require 'pure/compiler/ruby_parser'

describe Pure::Compiler::RubyParser do
  before :all do
    @compiler = Pure::Compiler::RubyParser.new
  end

  it "should transform `fun' definitions to `define_method' definitions" do
    def_f = pure(Pure::Parser::RubyParser) do
      def f(x, y)
        x + y
      end
    end
    
    fun_f = pure(Pure::Parser::RubyParser) do
      fun :f => [:x, :y] do |a, b|
        a + b
      end
    end

    def_g = pure(Pure::Parser::RubyParser) do
      def g
      end
    end

    fun_g = pure(Pure::Parser::RubyParser) do
      fun :g do
      end
    end

    def_h = pure(Pure::Parser::RubyParser) do
      def h(x)
        x**2
      end
    end

    fun_h = pure(Pure::Parser::RubyParser) do
      fun :h => :x do |a|
        a**2
      end
    end

    fun_i = pure(Pure::Parser::RubyParser) do
      fun :i => [:p, :q] do |*s|
        s.size
      end
    end

    fun_j = pure(Pure::Parser::RubyParser) do
      fun :j => [:p, :q] do |r, *s|
        r + s
      end
    end

    [
      [:def, def_f, :f, "def f(x, y) (x + y) end"],
      [:fun, fun_f, :f, "define_method(:f) { |a, b| (a + b) }"],
      [:def, def_g, :g, "def g # do nothing end"],
      [:fun, fun_g, :g, "define_method(:g) { }"],
      [:def, def_h, :h, "def h(x) (x ** 2) end"],
      [:fun, fun_h, :h, "define_method(:h) { |a| (a ** 2) }"],
      [:fun, fun_i, :i, "define_method(:i) { |*s| s.size }"],
      [:fun, fun_j, :j, "define_method(:j) { |r, *s| (r + s) }"],
    ].each { |type, mod, name, expected|
      entry = Pure::ExtractedFunctions[Pure::Parser::RubyParser][mod][name]
      entry[:code].should be_a(Sexp)
      sexp = Pure::Parser::RubyParser::DupSexp.dup_sexp(entry[:code])
      if entry[:origin] == :fun
        sexp = @compiler.fun_to_define_method(entry[:name], sexp)
      end
      recovered = Ruby2Ruby.new.process(sexp).strip.gsub(%r!\s+!, " ")
      recovered.should == expected
    }
  end
end

