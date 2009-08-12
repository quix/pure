require File.dirname(__FILE__) + '/pure_spec_base'

describe "Pure.worker" do
  it "should return the current worker" do
    Pure.worker.should_not == nil
  end

  it "should be changed with Pure.worker=" do
    lambda {
      mod = pure do
        def f
        end
      end
    }.should_not raise_error
    previous = Pure.worker
    Pure.worker = "junk"
    begin
      lambda {
        mod = pure do
          def f
          end
        end.compute.f
      }.should raise_error
    ensure
      Pure.worker = previous
    end
  end

  it "should have a default" do
    Pure.worker = nil
    Pure.worker.should_not == nil
  end
end
