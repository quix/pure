
module Pure
  module DSL
    #
    # Alias of Pure.define
    #
    def pure(*args, &block)
      Pure.define(*args, &block)
    end
  end
end
