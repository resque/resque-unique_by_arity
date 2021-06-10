# frozen_string_literal: true

require File.expand_path('lib/resque/unique_by_arity/version', __dir__)

Gem::Specification.new do |spec|
  spec.name          = 'resque-unique_by_arity'
  spec.version       = Resque::UniqueByArity::VERSION
  spec.authors       = ['Peter H. Boling']
  spec.email         = ['peter.boling@gmail.com']
  spec.license       = 'MIT'

  spec.summary       = 'Configure resque-unique_in_queue and resque-unique_at_runtime uniqueness by arity of perform method'
  spec.description   = 'Configure resque-unique_in_queue and resque-unique_at_runtime uniqueness by arity of perform method, with automated cleanup tools'
  spec.homepage      = 'https://github.com/pboling/resque-unique_by_arity'
  spec.required_ruby_version = '>= 2.3.0'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'colorize', '>= 0.8'
  spec.add_runtime_dependency 'resque', '>= 1.2'
  spec.add_runtime_dependency 'resque-unique_in_queue', '>= 2'
  spec.add_runtime_dependency 'resque-unique_at_runtime', '>= 3'

  spec.add_development_dependency 'bundler', '~> 2.0.2'
  spec.add_development_dependency 'byebug', '~> 11.0'
  spec.add_development_dependency 'pry', '~> 0.11'
  spec.add_development_dependency 'pry-byebug', '~> 3.6'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-block_is_expected', '~> 1.0'
  spec.add_development_dependency 'rspec-stubbed_env', '~> 1.0'
  spec.add_development_dependency 'rubocop', '~> 1.16'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.30'
end
