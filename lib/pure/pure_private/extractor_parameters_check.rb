
# rcov fun
has_parameters = Method.instance_methods.include?(:parameters)
require('pure/pure_private/extractor_parameters') if has_parameters
raise LoadError unless has_parameters
