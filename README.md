# Resque::UniqueByArity

NOTE:

Requires the pboling fork of resque-lonely_job at https://github.com/pboling/resque-lonely_job as the standard one is just very incompatible with resque-solo (or vice versa, either direction is true; they step on each other).

Usage:

```ruby
class MyJob
  include UniqueByArity::Cop.new(
    arity_for_uniqueness: 1,
    unique_at_runtime: true,
    unique_in_queue: true
  )
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'resque-unique_by_arity'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install resque-unique_by_arity

## Usage

```ruby
class MyJob
  include UniqueByArity::Cop.new(
    arity_for_uniqueness: 1,
    unique_at_runtime: true,
    unique_in_queue: true
  )
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pboling/resque-unique_by_arity.

