# rcov hack
has_parameters = Method.instance_methods.include?(:parameters)
require('pure/parser/impl/internal') if has_parameters
raise LoadError unless has_parameters
