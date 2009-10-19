$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../devel'

require 'pure/dsl'
require 'spec/autorun'

TOPLEVEL_INSTANCE = self

#
# verify compilers
#
module CompilerWorker
  class Base
    attr_reader :num_parallel
      
    def define_function(spec)
      lambda { |*args|
        self.class.compiler.new.evaluate_function(spec, *args)
      }
    end
    
    def define_function_begin(pure_module, num_parallel)
      @num_parallel = num_parallel || self.class.num_parallel
    end
      
    def define_function_end
    end
      
    class << self
      attr_accessor :num_parallel
      attr_reader :compiler
    end
  end

  Pure::BundledParsers.available.values.map { |parser|
    parser.compiler rescue nil
  }.compact.each { |path, name|
    names = name.split("::")
    worker = Class.new Base do
      require path
      @compiler = names.inject(Object) { |mod, name|
        mod.const_get(name)
      }
    end
    const_set(names.last, worker)
  }
end

module Spec::Example::ExampleGroupMethods
  alias_method :describe__original, :describe

  def describe(*args, &block)
    if args[1] and args[1][:scope] == TOPLEVEL_INSTANCE
      Pure::BundledParsers.available.each { |parser_path, parser|
        workers = [Pure::NativeWorker]

        name = parser.name.split("::").last
        name = name.to_sym if RUBY_VERSION >= "1.9"
        if CompilerWorker.constants.include?(name)
          workers << CompilerWorker.const_get(name)
        end

        describe "[#{parser.name}]" do
          before :each do
            @previous_parser = Pure.parser
            Pure.parser = parser
          end
          after :each do
            Pure.parser = @previous_parser
          end
          workers.each { |worker|
            describe "[#{worker}]" do
              before :all do
                @previous_worker = Pure.worker
                worker.num_parallel = @previous_worker.num_parallel
                Pure.worker = worker
              end
              after :all do
                Pure.worker = @previous_worker
              end
              describe args.first, &block
            end
          }
        end
      }
    else
      describe__original(*args, &block)
    end
  end
end

#
# Prevent Ruby2Ruby's destruction of the sexp.  In practice the
# compiler resides on another ruby interpreter, making the destruction
# harmless.
#
module Pure
  module Compiler
    class RubyParser
      alias_method :compile_function__original, :compile_function
      def compile_function(spec)
        compile_function__original(Marshal.load(Marshal.dump(spec)))
      end
    end
  end
end
