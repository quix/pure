
module Pure
  class Names
    attr_reader :fun_name, :arg_names
    def initialize(fun_name, arg_names)
      @fun_name, @arg_names = fun_name, arg_names
    end
  end
end
