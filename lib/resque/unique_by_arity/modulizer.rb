module Resque
  module UniqueByArity
    module Modulizer
      def self.to_mod(configuration)
        Module.new do
          if configuration.unique_in_queue || configuration.unique_at_runtime || configuration.unique_across_queues
            # @return [Array<String, arguments>] the key base hash used to enforce uniqueness, and the arguments from the payload used to calculate it
            define_method(:redis_unique_hash) do |payload|
              payload = Resque.decode(Resque.encode(payload))
              Resque::UniqueByArity.debug("payload is #{payload.inspect}")
              job  = payload['class']
              # It seems possible that some jobs may not have an "args" key in the payload.
              args = payload['args'] || []
              args.map! do |arg|
                arg.is_a?(Hash) ? arg.sort : arg
              end
              # what is the configured arity for uniqueness?
              uniqueness_args = if configuration.arity_for_uniqueness.zero?
                                  []
                                else
                                  # minus one because zero indexed, so
                                  #   when arity_for_uniqueness is 2 we use args
                                  #   at indexes 0 and 1.
                                  args[0..(configuration.arity_for_uniqueness - 1)]
                                end
              args = { class: job, args: uniqueness_args }
              return [Digest::MD5.hexdigest(Resque.encode(args)), uniqueness_args]
            end
          end

          if configuration.unique_in_queue || configuration.unique_across_queues
            ### Gem: resque-unique_in_queue
            ### Plugin Name: Resque::Plugins::UniqueJob
            ### Provides: Queue-time uniqueness for a single queue, or across queues
            #
            # Returns a string, used by Resque::Plugins::UniqueJob, that will be used as the prefix to the redis key
            define_method(:unique_in_queue_redis_key_prefix) do
              "unique_job:#{self}"
            end
            #
            # Returns a string, used by Resque::Plugins::UniqueJob, that will be used as the redis key
            # The example in the readme is bad.  The args passed to this method are like:
            # [{:class=>"MakeCompanyReport", :args=>[1]}]
            # Payload is what Resque stored for this job along with the job's class name:
            #   a hash containing :class and :args
            # @return [String] the key used to enforce uniqueness (at queue-time)
            define_method(:unique_in_queue_redis_key) do |queue, payload|
              unique_hash, args_for_uniqueness = redis_unique_hash(payload)
              key = "#{unique_in_queue_key_namespace(queue)}:#{unique_in_queue_redis_key_prefix}:#{unique_hash}"
              Resque::UniqueByArity.debug("#{self}.unique_in_queue_redis_key for #{args_for_uniqueness} is: #{ColorizedString[key].green}")
              key
            end
            #
            # @return [Fixnum] number of keys that were deleted
            define_method(:purge_unique_queued_redis_keys) do
              # unique_in_queue_key_namespace may or may not ignore the queue passed in, depending on config.
              key_match = "#{unique_in_queue_key_namespace(instance_variable_get(:@queue))}:#{unique_in_queue_redis_key_prefix}:*"
              keys = Resque.redis.keys(key_match)
              Resque::UniqueByArity.log("#{Resque::UniqueByArity::PLUGIN_TAG}#{Resque::UniqueInQueue::PLUGIN_TAG} #{ColorizedString['Purging'].red} #{keys.length} keys from #{ColorizedString[key_match].red}")
              Resque.redis.del keys unless keys.empty?
            end

            if configuration.unique_in_queue
              # @return [String] the Redis namespace of the key used to enforce uniqueness (at queue-time)
              define_method(:unique_in_queue_key_namespace) do |queue = nil|
                "#{unique_in_queue_key_base}:queue:#{queue}:job"
              end
            elsif configuration.unique_across_queues
              # @return [String] the Redis namespace of the key used to enforce uniqueness (at queue-time)
              define_method(:unique_in_queue_key_namespace) do |_queue = nil|
                "#{unique_in_queue_key_base}:across_queues:job"
              end
            end
          end

          ### Gem: resque-unique_at_runtime
          ### Plugin Name: Resque::Plugins::UniqueAtRuntime
          ### Provides: Runtime uniqueness across queues
          if configuration.unique_at_runtime
            # @return [String] the Redis namespace of the key used to enforce uniqueness (at runtime)
            define_method(:runtime_key_namespace) do
              "#{unique_at_runtime_key_base}:#{self}"
            end
            # Returns a string, used by Resque::Plugins::UniqueAtRuntime, that will be used as the redis key
            # The versions of redis_key from resque-solo and resque-lonely_job are incompatible.
            # So I forked and namespaced the methods according to the gem handling the key.
            #   Now I can override it, and fix the params to be compatible.
            # Does not need any customization for arity, because ultimately it
            #   still funnels down to redis_key, and we handle the arity option there
            # @return [String] the key used to enforce loneliness (uniqueness at runtime)
            define_method(:unique_at_runtime_redis_key) do |*args|
              unique_hash, args_for_uniqueness = redis_unique_hash('class' => to_s, 'args' => args)
              key = "#{runtime_key_namespace}:#{unique_hash}"
              Resque::UniqueByArity.debug("#{Resque::UniqueAtRuntime::PLUGIN_TAG} #{self}.unique_at_runtime_redis_key for #{args_for_uniqueness} is: #{ColorizedString[key].yellow}")
              key
            end
            # @return [Fixnum] number of keys that were deleted
            define_method(:purge_unique_at_runtime_redis_keys) do
              key_match = "#{runtime_key_namespace}:*"
              keys = Resque.redis.keys(key_match)
              Resque::UniqueByArity.log("#{Resque::UniqueByArity::PLUGIN_TAG}#{Resque::UniqueAtRuntime::PLUGIN_TAG} #{ColorizedString['Purging'].red} #{keys.length} keys from #{ColorizedString[key_match].red}")
              Resque.redis.del keys unless keys.empty?
            end
          end
        end
      end
    end
  end
end
