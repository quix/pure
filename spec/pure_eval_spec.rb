require File.dirname(__FILE__) + '/pure_spec_base'

describe "pure" do
  describe "defined inside eval" do
    it "should raise an error" do
      lambda {
        code = %{
          pure do
            def f
              33
            end
          end
        }
        eval(code)
      }.should raise_error(Pure::EvalError, %r!#{__FILE__}:14!)
    end
  end
end
