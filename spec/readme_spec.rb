require File.dirname(__FILE__) + '/pure_spec_base'

require "jumpstart"

readme = "README.rdoc"

simple_sections = [
 "Synopsis",
 "Overrides",
 "Delegates and Blocks",
 "Combining Pure Modules",
 "Restrictions",
 "Default Number of Functions in Parallel",
]

Jumpstart.doc_to_spec(readme, *simple_sections)

sections = ["Dynamic Names", "Mapping an Enumerable in Parallel"]
Jumpstart.doc_to_spec(readme, *sections) { |expected, actual, index|
  if index == 1
    [expected, actual].each { |expr|
      expr.should match(%r!\A[\d\s]+\Z!)
    }
  else
    expected.should == actual
  end
}

Jumpstart.doc_to_spec(readme, "Worker Plugins") { |expected, actual, index|
  case index
  when 0, 2
    actual.should == expected
  when 1
    require 'ruby_parser'
    trimmed_expected, trimmed_actual = [expected, actual].map { |expression|
      result = eval(expression, TOPLEVEL_BINDING)
      result[0].merge!(:file => nil, :line => nil)
      result
    }
    trimmed_actual.should == trimmed_expected
  else
    raise
  end
}
