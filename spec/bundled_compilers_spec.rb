require File.dirname(__FILE__) + '/pure_spec_base'

describe "bundled compilers" do
  it "should raise error when no compiler found" do
    source = File.dirname(__FILE__) + "/../lib/pure/compiler"
    dest = source + "-tmp"
    FileUtils.mv(source, dest)
    begin
      lambda {
        Pure::BundledCompilers.find_default
      }.should raise_error(Pure::NoCompilerError, "no compiler found")
    ensure
      FileUtils.mv(dest, source)
    end
  end
end
