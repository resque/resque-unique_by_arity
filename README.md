# Resque::UniqueByArity

Because some jobs have parameters that you do not want to consider for
determination of uniqueness.

NOTE:

I rewrote, and renamed, both `resque_solo` and `resque-lonely_job`, because they
 can't be used together.  Why?  Their `redis_key` methods directly conflict,
 among other more subtle issues.

This gem requires use of my rewritten gems for uniqueness enforcement:

  - [`resque-unique_at_runtime`](https://github.com/pboling/resque-unique_at_runtime)
  - [`resque-unique_in_queue`](https://github.com/pboling/resque-unique_in_queue)

| Project                 |  Resque::UniqueByArity |
|------------------------ | ----------------------- |
| gem name                |  [resque-unique_by_arity](https://rubygems.org/gems/resque-unique_by_arity) |
| license                 |  [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT) |
| download rank           |  [![Downloads Today](https://img.shields.io/gem/rd/resque-unique_by_arity.svg)](https://github.com/pboling/resque-unique_by_arity) |
| version                 |  [![Version](https://img.shields.io/gem/v/resque-unique_by_arity.svg)](https://rubygems.org/gems/resque-unique_by_arity) |
| dependencies            |  [![Depfu](https://badges.depfu.com/badges/25c6e1e4c671926e9adea898f2df9a47/count.svg)](https://depfu.com/github/pboling/resque-unique_by_arity?project_id=2729) |
| continuous integration  |  [![Build Status](https://travis-ci.org/pboling/resque-unique_by_arity.svg?branch=master)](https://travis-ci.org/pboling/resque-unique_by_arity) |
| test coverage           |  [![Test Coverage](https://api.codeclimate.com/v1/badges/7520df3968eb146c8894/test_coverage)](https://codeclimate.com/github/pboling/resque-unique_by_arity/test_coverage) |
| maintainability         |  [![Maintainability](https://api.codeclimate.com/v1/badges/7520df3968eb146c8894/maintainability)](https://codeclimate.com/github/pboling/resque-unique_by_arity/maintainability) |
| code triage             |  [![Open Source Helpers](https://www.codetriage.com/pboling/resque-unique_by_arity/badges/users.svg)](https://www.codetriage.com/pboling/resque-unique_by_arity) |
| homepage                |  [on Github.com][homepage], [on Railsbling.com][blogpage] |
| documentation           |  [on RDoc.info][documentation] |
| Spread ~♡ⓛⓞⓥⓔ♡~      |  [🌏](https://about.me/peter.boling), [👼](https://angel.co/peter-boling), [:shipit:](http://coderwall.com/pboling), [![Tweet Peter](https://img.shields.io/twitter/follow/galtzo.svg?style=social&label=Follow)](http://twitter.com/galtzo) |

## Important Note

See `lib/resque/unique_by_arity/configuration.rb` for all config options.  Only
 a smattering of what is available is documented in this README.

## Most Important Note

You must configure this gem *after* you define the perform class method in your
 job or an error will be raised thanks to `perform` not having been defined yet.

Example:

```ruby
class MyJob
  def self.perform(arg)
    # do stuff
  end
  include Resque::Plugins::UniqueByArity.new(
    arity_for_uniqueness: 1,
    lock_after_execution_period: 60,
    runtime_lock_timeout: 60 * 60 * 24 * 5, # 5 days
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

### Global Configuration

The following is showing the default values.  These global configs are copied into each per-class config unless they are overridden by the class config.


Create an initializer (e.g. `config/initializers/resque-unique_by_arity.rb` for rails) and customize the following:

```ruby
  Resque::UniqueByArity.configure do |config|
    config.logger = nil
    config.log_level = :debug
    config.arity_for_uniqueness = 0
    config.unique_at_runtime = false
    config.unique_in_queue = false
    # No need to do the following if keeping default values
    config.runtime_lock_timeout = 60 * 60 * 24 * 5
    config.runtime_requeue_interval = 1
    config.unique_at_runtime_key_base = 'r-uar'.freeze
    config.lock_after_execution_period = 0
    config.ttl = -1
    config.unique_in_queue_key_base = 'r-uiq'.freeze
    # Debug Mode is preferably set via an environment variable:
    #   to one of 'true', 'arity', or 'arity,queue,runtime' for all three tools:
    #     ENV['RESQUE_DEBUG'] = 'true'
    # config.debug_mode = true
  end
```

### Per Job Class Configuration

This gem will take care to set the class instance variables (similar to the
 familiar `@queue` class instance variable) that are utilized by
 `resque-unique_in_queue` and `resque-unique_at_runtime` (default values shown):

 ```ruby
# For resque-unique_at_runtime
@runtime_lock_timeout = 60 * 60 * 24 * 5
@runtime_requeue_interval = 1
@unique_at_runtime_key_base = 'r-uar'.freeze

# For resque-unique_in_queue
@lock_after_execution_period = 0
@ttl = -1
@unique_in_queue_key_base = 'r-uiq'.freeze
```

All you need to do is configure this gem accordingly:
```ruby
  include Resque::Plugins::UniqueByArity.new(
    arity_for_uniqueness: 1,
    # Turn on one or both of the following:
    unique_at_runtime: false,
    unique_in_queue: false,
    # No need to do the following if keeping default values
    runtime_lock_timeout: 60 * 60 * 24 * 5,
    runtime_requeue_interval: 1,
    # would override the global setting, probably a bad idea.
    # unique_at_runtime_key_base: 'r-uar'.freeze,
    lock_after_execution_period: 0,
    ttl: -1,
    # would override the global setting, probably a bad idea.
    # unique_in_queue_key_base: 'r-uiq'.freeze
  )
```

### Arity For Uniqueness

Some jobs have parameters that you do not want to consider for determination of
 uniqueness.  Resque jobs should use simple parameters, **not named parameters**,
  so you can just specify the number of parameters, counting from the left, you
   want to be considered for uniqueness.

```ruby
class MyJob
  def self.perform(my, cat, is, the, best, opts = {})
    # Only the first 3: [my, cat, is] will be considered for determination of uniqueness
  end
  include Resque::Plugins::UniqueByArity.new(
    arity_for_uniqueness: 3,
    unique_at_runtime: true
  )
end
```

#### Arity For Uniqueness Validation

Want this gem to tell you when it is misconfigured?  It can.

```ruby
class MyJob
  def self.perform(my, cat, opts = {})
    # Because the third argument is optional the arity valdiation will not approve.
    # Arguments to be considered for uniqueness should be required arguments.
    # The warning log might look like:
    #
    #    MyJob.perform has the following required parameters: [:my, :cat], which is not enough to satisfy the configured arity_for_uniqueness of 3
  end
  include Resque::Plugins::UniqueByArity.new(
    arity_for_uniqueness: 3,
    arity_validation: :warning, # or :skip, :error, or an error class to be raised, e.g. RuntimeError
    unique_at_runtime: true
  )
end
```


### Lock After Execution

Give the job a break after it finishes running, and don't allow another of the
 same, with matching args @ configured arity, to start within X seconds.

```ruby
class MyJob
  def self.perform(arg1)
    # do stuff
  end
  include Resque::Plugins::UniqueByArity.new(
    arity_for_uniqueness: 1,
    lock_after_execution_period: 60,
    unique_at_runtime: true
  )
end
```

### Runtime Lock Timeout

If runtime lock keys get stale, they will expire on their own after some period.
  You can set the expiration period on a per class basis.

```ruby
class MyJob
  def self.perform(arg1)
    # do stuff
  end
  include Resque::Plugins::UniqueByArity.new(
    arity_for_uniqueness: 1,
    runtime_lock_timeout: 60 * 60 * 24 * 5, # 5 days
    unique_at_runtime: true
  )
end
```

### Unique At Runtime (across all queues)

Prevent your app from running a job that is already running.

```ruby
class MyJob
  def self.perform(arg1)
    # do stuff
  end
  include Resque::Plugins::UniqueByArity.new(
    arity_for_uniqueness: 1,
    unique_at_runtime: true
  )
end
```

#### Oops, I have stale runtime uniqueness keys for MyJob stored in Redis...

Preventing jobs with matching signatures from running, and they never get
dequeued because there is no actual corresponding job to dequeue.

*How to deal?*

```ruby
MyJob.purge_unique_at_runtime_redis_keys
```

### Unique At Queue Time

#### Unique In Job's Specific Queue

Prevent your app from queueing a job that is already queued in the same queue.

```ruby
class MyJob
  def self.perform(arg1)
    # do stuff
  end
  include Resque::Plugins::UniqueByArity.new(
    arity_for_uniqueness: 1,
    unique_in_queue: true
  )
end
```

#### Unique Across All Queues

Prevent your app from queueing a job that is already queued in *any* queue.

```ruby
class MyJob
  def self.perform(arg1)
    # do stuff
  end
  include Resque::Plugins::UniqueByArity.new(
    arity_for_uniqueness: 1,
    unique_across_queues: true
  )
end
```

#### Oops, I have stale Queue Time uniqueness keys...

Preventing jobs with matching signatures from being queued, and they never get
dequeued because there is no actual corresponding job to dequeue.

*How to deal?*

Option: Rampage

```ruby
# Delete *all* queued jobs in the queue, and
#   delete *all* uniqueness keys for the queue.
Redis.remove_queue('queue_name')
```

Option: Butterfly

```ruby
# Delete *no* queued jobs at all, and
#   delete *all* uniqueness keys for the queue (might then allow duplicates).
Resque::UniqueInQueue::Queue.cleanup('queue_name')
```

### All Together Now

#### Unique At Runtime (across all queues) AND Unique In Job's Specific Queue

Prevent your app from running a job that is already running, **and**
prevent your app from queueing a job that is already queued in the same queue.

```ruby
class MyJob
  def self.perform(arg1)
    # do stuff
  end
  include Resque::Plugins::UniqueByArity.new(
    arity_for_uniqueness: 1,
    unique_at_runtime: true,
    runtime_lock_timeout: 60 * 60 * 24 * 5, # 5 days
    unique_in_queue: true
  )
end
```

#### Unique At Runtime (across all queues) AND Unique Across All Queues

Prevent your app from running a job that is already running, **and**
prevent your app from queueing a job that is already queued in *any* queue.

```ruby
class MyJob
  def self.perform(arg1)
    # do stuff
  end
  include Resque::Plugins::UniqueByArity.new(
    arity_for_uniqueness: 1,
    unique_at_runtime: true,
    runtime_lock_timeout: 60 * 60 * 24 * 5, # 5 days
    unique_across_queues: true
  )
end
```

### Debugging

Run your worker with `RESQUE_DEBUG=true` to see payloads printed before they are
 used to determine uniqueness, as well as a lot of other debugging output.

### Customize Unique Keys Per Job

Redefine methods to customize all the things.  Warning: This might be crazy-making.

```ruby
class MyJob
  def self.perform(arg1)
    # do stuff
  end
  include Resque::Plugins::UniqueByArity.new(
    #...
  )

  # Core hashing algorithm for a job used for *all 3 types* of uniqueness
  # @return [Array<String, arguments>], where the string is the unique digest, and arguments are the specific args that were used to calculate the digest
  def self.redis_unique_hash(payload, arity_for_uniqueness = 1)
    #       for how the built-in version works
    # uniqueness_args = payload["args"] # over simplified & ignoring arity
    # args = { class: job, args: uniqueness_args }
    # return [Digest::MD5.hexdigest(Resque.encode(args)), uniqueness_args]
  end

  def self.unique_in_queue_redis_key_prefix
    # "unique_job:#{self}" # <= default value
  end

  def self.unique_in_queue_redis_key(queue, payload)
    # arity_for_uniqueness = determine_arity # over simplified & ignoring context-specific arity determination
    # unique_hash, _args_for_uniqueness = redis_unique_hash(payload, arity_for_uniqueness)
    # "#{unique_in_queue_key_namespace(queue)}:#{unique_in_queue_redis_key_prefix}:#{unique_hash}"
  end

  def self.unique_in_queue_key_namespace(queue = nil)
    # definition depends on which type of uniqueness is chosen, be careful if you customize
    # "r-uiq:queue:#{queue}:job" # <= is for unique within queue at queue time
    # "r-uiq:across_queues:job" # <= is for unique across all queues at queue time
  end

  def self.runtime_key_namespace
    # "unique_at_runtime:#{self}"
  end

  def self.unique_at_runtime_redis_key(*args)
    # payload = {"class" => self.to_s, "args" => args}
    # unique_hash, _args_for_uniqueness = redis_unique_hash(payload, configuration.arity_for_uniqueness_at_runtime)
    # key = "#{runtime_key_namespace}:#{unique_hash}" # <= simplified default
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pboling/resque-unique_by_arity. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Code of Conduct

Everyone interacting in the Resque::UniqueByArity project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/pboling/resque-unique_by_arity/blob/master/CODE_OF_CONDUCT.md).

## Versioning

This library aims to adhere to [Semantic Versioning 2.0.0][semver].
Violations of this scheme should be reported as bugs. Specifically,
if a minor or patch version is released that breaks backward
compatibility, a new version should be immediately released that
restores compatibility. Breaking changes to the public API will
only be introduced with new major versions.

As a result of this policy, you can (and should) specify a
dependency on this gem using the [Pessimistic Version Constraint][pvc] with two digits of precision.

For example:

```ruby
spec.add_dependency 'resque-unique_by_arity', '~> 0.0'
```


## License

* Copyright (c) 2017 - 2018 [Peter H. Boling][peterboling] of [Rails Bling][railsbling]

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

[license]: LICENSE
[semver]: http://semver.org/
[pvc]: http://guides.rubygems.org/patterns/#pessimistic-version-constraint
[railsbling]: http://www.railsbling.com
[peterboling]: http://www.peterboling.com
[documentation]: http://rdoc.info/github/pboling/resque-unique_by_arity/frames
[homepage]: https://github.com/pboling/resque-unique_by_arity/
[blogpage]: http://www.railsbling.com/tags/resque-unique_by_arity/
