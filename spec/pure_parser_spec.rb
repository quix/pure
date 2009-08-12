require File.dirname(__FILE__) + '/pure_spec_base'

describe "Pure.parser" do
  it "should return the current parser" do
    Pure.parser.should_not == nil
  end

  it "should have a default" do
    Pure.parser = nil
    pure do
      def f
      end
    end.compute(Pure::NativeWorker).f
    Pure.parser.should_not == nil
  end

  it "should be changed with Pure.parser=" do
    lambda {
      mod = pure do
        def f
        end
      end
    }.should_not raise_error
    previous = Pure.parser
    Pure.parser = "junk"
    begin
      lambda {
        mod = pure do
          def f
          end
        end
      }.should raise_error
    ensure
      Pure.parser = previous
    end
  end

  it "should raise error when no parser found" do
    source = File.dirname(__FILE__) + "/../lib/pure/parser"
    dest = source + "-tmp"
    FileUtils.mv(source, dest)
    begin
      lambda {
        Pure::BundledParsers.find_default
      }.should raise_error(Pure::NoParserError, "no parser found")
    ensure
      FileUtils.mv(dest, source)
    end
  end
end
