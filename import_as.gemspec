
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "import_as/version"

Gem::Specification.new do |spec|
  spec.name          = "import_as"
  spec.version       = ImportAs::VERSION
  spec.authors       = ["Seiei Miyagi"]
  spec.email         = ["hanachin@gmail.com"]

  spec.summary       = %q{Add DSL: import { C as C2 }.from "./c.rb"}
  spec.homepage      = "https://github.com/hanachin/import_as"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version =">= 2.6.0"
  spec.add_development_dependency "bundler", "~> 2.0.a"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
