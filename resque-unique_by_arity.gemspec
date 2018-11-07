lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resque/unique_by_arity/version'

Gem::Specification.new do |spec|
  spec.name          = 'resque-unique_by_arity'
  spec.version       = Resque::UniqueByArity::VERSION
  spec.authors       = ['Peter Boling']
  spec.email         = ['peter.boling@gmail.com']
  spec.license       = 'MIT'

  spec.summary       = 'Magic hacks which allow integration of resque_solo and resque-unique_at_runtime_simultaneously into Resque jobs'
  spec.description   = 'fixes incompatibilities between resque_solo and resque-unique_at_runtime'
  spec.homepage      = 'https://github.com/pboling/resque-unique_by_arity'
  spec.required_ruby_version = '>= 2.0.0'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'colorize', '~> 0.8'
  spec.add_runtime_dependency 'resque-unique_at_runtime', '~> 2.0'
  spec.add_runtime_dependency 'resque_solo', '~> 0.3'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'byebug', '~> 10.0'
  spec.add_development_dependency 'pry', '~> 0.11'
  spec.add_development_dependency 'pry-byebug', '~> 3.6'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-block_is_expected', '~> 1.0'
  spec.add_development_dependency 'rubocop', '~> 0.60'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.30'
end
