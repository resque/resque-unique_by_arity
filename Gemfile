source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'resque-unique_at_enqueue', path: '/Users/pboling/Documents/code/intricately/resque-unique_at_enqueue'
gem 'resque-unique_at_runtime', path: '/Users/pboling/Documents/code/intricately/resque-unique_at_runtime'

group :test do
  unless ENV['TRAVIS']
    gem 'byebug', '~> 10', platform: :mri, require: false
    gem 'pry', '~> 0', platform: :mri, require: false
    gem 'pry-byebug', '~> 3', platform: :mri, require: false
  end
  gem 'rubocop', '~> 0.60.0'
  gem 'rubocop-rspec', '~> 1.30.0'
  gem 'simplecov', '~> 0', require: false
end

# Specify your gem's dependencies in resque-unique_by_arity.gemspec
gemspec
