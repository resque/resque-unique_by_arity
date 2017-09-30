module Resque
  module UniqueByArity
    module CopModulizer
      def self.to_mod(configuration)
        Module.new do
          if configuration.unique_in_queue || configuration.unique_at_runtime
            # @return [Array<String, arguments>] the key base hash used to enforce uniqueness, and the arguments from the payload used to calculate it
            define_method(:redis_unique_hash) do |payload|
              payload = Resque.decode(Resque.encode(payload))
              job  = payload["class"]
              # It seems possible that some jobs may not have an "args" key in the payload.
              args = payload["args"] || []
              args.map! do |arg|
                arg.is_a?(Hash) ? arg.sort : arg
              end
              # what is the configured arity for uniqueness?
              # minus one because zero indexed
              uniqueness_args = args[0..(configuration.arity_for_uniqueness - 1)]
              args = { class: job, args: uniqueness_args }
              return [Digest::MD5.hexdigest(Resque.encode(args)), uniqueness_args]
            end
          end
          if configuration.unique_in_queue
            # Returns a string, used by LonelyJob, that will be used as the redis key
            # The example in the readme is bad.  The args passed to this method are like:
            # [{:class=>"MakeCompanyReport", :args=>[1]}]
            # This is identical to the version from Resque::Plugins::UniqueJob
            # and we do not want the version from Resque::Plugins::LonelyJob to be used.
            # Payload is what Resque stored for this job along with the job's class name:
            #   a hash containing :class and :args
            # @return [String] the key used to enforce uniqueness (at queue-time)
            define_method(:redis_key) do |payload|
              unique_hash, args_for_uniqueness = redis_unique_hash(payload)
              key = "unique_job:#{self}:#{unique_hash}"
              puts "#{self}.redis_key for #{args_for_uniqueness} is: #{key.green}"
              key
            end
            # @return [Fixnum] number of keys that were deleted
            define_method(:purge_unique_job_redis_keys) do
              keys = Resque.redis.keys("unique_job:#{self}:*")
              Resque.redis.del keys if keys.length > 0
            end
          end
          if configuration.unique_at_runtime
            # The versions of redis_key from resque_solo and resque-lonely_job are incompatible.
            # So we forked resque-lonely_job, change the name of the method so it would not conflict,
            #   and now we can override it, and fix the params to be compatible with the redis_key
            #   from resque_solo
            # Does not need any customization for arity, because it funnels down to redis_key,
            #   and we handle the arity option there
            # @return [String] the key used to enforce loneliness (uniqueness at runtime)
            define_method(:lonely_job_redis_key) do |*args|
              unique_hash, args_for_uniqueness = redis_unique_hash({"class" => self.to_s, "args" => args})
              key = "lonely_job:#{self}:#{unique_hash}"
              puts "#{self}.lonely_job_redis_key for #{args_for_uniqueness} is: #{key.yellow}"
              key
            end
            # @return [Fixnum] number of keys that were deleted
            define_method(:purge_lonely_job_redis_keys) do
              keys = Resque.redis.keys("lonely_job:#{self}:*")
              Resque.redis.del keys if keys.length > 0
            end
          end
        end
      end
    end
  end
end
