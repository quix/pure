require File.dirname(__FILE__) + "/common"

$LOAD_PATH.unshift File.dirname(__FILE__) + "/../devel"
require "jumpstart"

readme = "README.rdoc"

Jumpstart.doc_to_spec(readme, "Synopsis")

Jumpstart.doc_to_spec(readme, "Dynamic Example") { |expected, actual|
  # check for numbers, not values
  [actual, expected].each { |expr|
    unless expr =~ %r!\A\d+\Z!
      raise "readme failed"
    end
  }
  [nil, nil]
}

Jumpstart.doc_to_spec(readme, "Sexp Example") { |*expressions|
  expressions.map { |expresssion|
    result = eval(expresssion, TOPLEVEL_BINDING)
    result[:add].merge!(:file => nil, :line => nil)
    result
  }
}
