$LOAD_PATH.unshift "devel"
require "jumpstart"

Jumpstart.new "pure" do |s|
  s.developers << ["James M. Lawrence", "quixoticsycophant@gmail.com"]
  s.github_user = "quix"

  s.dependencies = [
    ["comp_tree", ">= 1.0.0"],
    ["ruby_parser", ">= 2.0.4"],
  ]
                    
  s.development_dependencies = [
    ["ruby2ruby", ">= 1.2.2"],
    ["rspec", ">= 1.2.6"],
  ]

  s.rdoc_files = %w[
    lib/pure/pure.rb
    lib/pure/pure_module.rb
    lib/pure/dsl.rb
    lib/pure/dsl_definition.rb
  ]
end

readme = "README.rdoc"
task readme do
  re = %r!(The\s+default\s+worker\s+looks\s+like\s+this:).*?(?=^\S)!m
  contents = File.read(readme).sub(re) { |sentence|
    $1 + "\n" + 
    File.read("lib/pure/native_worker.rb").
    gsub(%r!^!, "  ").
    sub(%r!  \#:nodoc:!, "") + "\n"
  }
  File.open(readme, "w") { |f| f.print contents }
end
