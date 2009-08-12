
module Pure
  class Delegate
    def initialize(driver)
      (class << self ; self ; end).class_eval do
        driver.each_function_name { |name|
          define_method name do ||
            driver.compute(name)
          end
        }
      end
    end
    
    alias_method :[], :send
  end
end
