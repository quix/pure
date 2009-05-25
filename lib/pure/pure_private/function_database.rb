
module Pure
  module PurePrivate
    FunctionDatabase = Hash.new { |hash, key|
      hash[key] = Hash.new
    }
  end
end
