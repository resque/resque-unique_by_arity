# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resque/unique_by_arity/version'

Gem::Specification.new do |spec|
  spec.name          = "resque-unique_by_arity"
  spec.version       = Resque::UniqueByArity::VERSION
  spec.authors       = ["Peter Boling"]
  spec.email         = ["peter.boling@gmail.com"]

  spec.summary       = %q{Magic hacks which allow integration of resque_solo  and resque-lonely_simlutaneously into Resque jobs}
  spec.description   = %q{resque_solo  and resque-lonely are incompatible - fixes that}
  spec.homepage      = "https://github.com/pboling/resque-unique_by_arity"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "resque-lonely_job"
  spec.add_runtime_dependency "resque_solo"
  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
