require File.dirname(__FILE__) + '/pure_spec_base'

def check_sexp(type, mod, name, expected)
  entry = Pure::ExtractedFunctions[Pure.parser][mod][name]
  if Pure.parser == (Pure::Parser::RubyParser rescue nil)
    check_ruby_parser_sexp(entry, type, mod, expected)
  elsif Pure.parser == (Pure::Parser::Ripper rescue nil)
    check_ripper_sexp(entry, type, mod, expected)
  elsif Pure.parser == (Pure::Parser::Internal rescue nil)
    check_internal_sexp(entry, type, mod, expected)
  end
end

def check_ruby_parser_sexp(entry, type, mod, expected)
  entry[:code].should be_a(Sexp)
  sexp = Pure::Parser::RubyParser::DupSexp.dup_sexp(entry[:code])
  require 'ruby2ruby'
  recovered = Ruby2Ruby.new.process(sexp).strip.gsub(%r!\s+!, " ")
  recovered.should == expected
end

def check_ripper_sexp(entry, type, mod, expected)
  sexp = entry[:code]
  sexp.should be_a(Array)
  case entry[:origin]
  when :def
    sexp.first.should == :def
  when :fun
    sexp.first.should == :do_block
  end
end

def check_internal_sexp(entry, type, mod, expected)
  entry[:code].should == nil
end

describe "parser" do
  describe "sexp" do
    it "should match the source" do
      def_f = pure do
        def f(x, y)
          x + y
        end
      end
      
      fun_f = pure do
        fun :f => [:x, :y] do |a, b|
          a + b
        end
      end
  
      def_g = pure do
        def g
        end
      end
  
      fun_g = pure do
        fun :g do
        end
      end
  
      def_h = pure do
        def h(x)
          x**2
        end
      end
  
      fun_h = pure do
        fun :h => :x do |a|
          a**2
        end
      end
  
      fun_i = pure do
        fun :i => [:p, :q] do |*s|
          s.size
        end
      end
  
      fun_j = pure do
        fun :j => [:p, :q] do |r, *s|
          r + s
        end
      end
  
      [
        [:def, def_f, :f, "def f(x, y) (x + y) end"],
        [:fun, fun_f, :f, "fun(:f => ([:x, :y])) { |a, b| (a + b) }"],
        [:def, def_g, :g, "def g # do nothing end"],
        [:fun, fun_g, :g, "fun(:g) { }"],
        [:def, def_h, :h, "def h(x) (x ** 2) end"],
        [:fun, fun_h, :h, "fun(:h => :x) { |a| (a ** 2) }"],
        [:fun, fun_i, :i, "fun(:i => ([:p, :q])) { |*s| s.size }"],
        [:fun, fun_j, :j, "fun(:j => ([:p, :q])) { |r, *s| (r + s) }"],
      ].each { |type, mod, name, expected|
        check_sexp(type, mod, name, expected)
      }
    end
  end
end
