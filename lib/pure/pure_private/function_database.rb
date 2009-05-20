
module Pure
  module PurePrivate
    module FunctionDatabase
      FUNCTION_DATABASE = Hash.new { |hash, key|
        hash[key] = Hash.new
      }
    end
  end
end
