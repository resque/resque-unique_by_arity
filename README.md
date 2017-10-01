# Resque::UniqueByArity

NOTE:

Requires `resque_solo` gem, and `resque-unique_at_runtime` gem; the latter is a fork of `resque-lonely_job`.
Why? `resque-lonely_job` and `resque_solo` can't be used together, because their `redis_key` methods conflict.

Example:

```ruby
class MyJob
  include UniqueByArity::Cop.new(
    arity_for_uniqueness: 1,
    lock_after_execution_period: 60,
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

### Arity For Uniqueness

Some jobs have parameters that you do not want to consider for determination of uniqueness.  Resque jobs should use simple parameters, **not named parameters**, so you can just specify the number of parameters, counting from the left, you want to be considered for uniqueness.

```ruby
class MyJob
  include UniqueByArity::Cop.new(
    arity_for_uniqueness: 3,
    unique_at_runtime: true
  )
  def self.perform(my, cat, is, the, best, opts = {})
    # Only the first 3: [my, cat, is] will be considered for determination of uniqueness
  end
end
```

### Lock After Execution

Give the job a break after it finishes running, and don't allow another of the same, with matching args @ configured arity, to start within X seconds.

```ruby
class MyJob
  include UniqueByArity::Cop.new(
    arity_for_uniqueness: 1,
    lock_after_execution_period: 60,
    unique_at_runtime: true
  )
end
```

### Unique At Runtime (across all queues)

Prevent your app from running a job that is already running.

```ruby
class MyJob
  include UniqueByArity::Cop.new(
    arity_for_uniqueness: 1,
    unique_at_runtime: true
  )
end
```

### Unique At Queue Time

#### Unique In Job's Specific Queue

Prevent your app from queueing a job that is already queued in the same queue.

```ruby
class MyJob
  include UniqueByArity::Cop.new(
    arity_for_uniqueness: 1,
    unique_in_queue: true
  )
end
```

#### Unique Across All Queues

Prevent your app from queueing a job that is already queued in *any* queue.

```ruby
class MyJob
  include UniqueByArity::Cop.new(
    arity_for_uniqueness: 1,
    unique_across_queues: true
  )
end
```

### All Together Now

#### Unique At Runtime (across all queues) AND Unique In Job's Specific Queue

Prevent your app from running a job that is already running, **and**
prevent your app from queueing a job that is already queued in the same queue.

```ruby
class MyJob
  include UniqueByArity::Cop.new(
    arity_for_uniqueness: 1,
    unique_at_runtime: true,
    unique_in_queue: true
  )
end
```

#### Unique At Runtime (across all queues) AND Unique Across All Queues

Prevent your app from running a job that is already running, **and**
prevent your app from queueing a job that is already queued in *any* queue.

```ruby
class MyJob
  include UniqueByArity::Cop.new(
    arity_for_uniqueness: 1,
    unique_at_runtime: true,
    unique_across_queues: true
  )
end
```

### Debugging

Run your worker with `RESQUE_DEBUG=true` to see payloads printed before they are used to determine uniqueness.

### Customize Unique Keys Per Job

Redefine methods to customize all the things.  Warning: This might be crazy-making.

```ruby
class MyJob
  include UniqueByArity::Cop.new(
    #...
  )

  # Core hashing algorithm for a job used for *all 3 types* of uniqueness 
  # @return [Array<String, arguments>], where the string is the unique digest, and arguments are the specific args that were used to calculate the digest 
  def self.redis_unique_hash(payload)
    # ... See source @ lib/resque/unique_by_arity/cop_modulizer.rb 
    #       for how the built-in version works
    # uniqueness_args = payload["args"] # over simplified & ignoring arity
    # args = { class: job, args: uniqueness_args }
    # return [Digest::MD5.hexdigest(Resque.encode(args)), uniqueness_args]
  end

  # Prefix to the unique key for a job for resque_solo, queue time uniqueness 
  def self.solo_redis_key_prefix
    # "unique_job:#{self}" # <= default value
  end

  # Prefix to the unique redis key for a job for resque_solo, queue time uniqueness 
  def self.solo_key_namespace(queue = nil)
    # definition depends on which type of uniqueness is chosen, be careful if you customize
    # "solo:queue:#{queue}:job" # <= is for unique within queue at queue time
    # "solo:across_queues:job" # <= is for unique across all queues at queue time
  end
  
  def self.unique_at_queue_time_redis_key(queue, payload)
    # unique_hash, _args_for_uniqueness = redis_unique_hash(payload)
    # "#{solo_key_namespace(queue)}:#{solo_redis_key_prefix}:#{unique_hash}"
  end
  
  def self.runtime_key_namespace
    # "unique_at_runtime:#{self}"
  end
  
  def self.unique_at_runtime_redis_key(*args)
    # unique_hash, _args_for_uniqueness = redis_unique_hash({"class" => self.to_s, "args" => args})
    # key = "#{runtime_key_namespace}:#{unique_hash}" # <= simplified default
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pboling/resque-unique_by_arity.

