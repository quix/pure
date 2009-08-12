
module Pure
  #
  # ExtractedFunctions[parser][pure_module][function_name] = function_data
  #
  ExtractedFunctions = Hash.new { |hash, key|
    hash[key] = Hash.new { |h, k|
      h[k] = Hash.new
    }
  }
end
