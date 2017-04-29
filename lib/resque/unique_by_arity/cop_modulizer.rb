module Resque
  module UniqueByArity
    module CopModulizer
      def self.to_mod(configuration)
        Module.new do
          if configuration.unique_in_queue
            # Returns a string, used by LonelyJob, that will be used as the redis key
            # The example in the readme is bad.  The args passed to this method are like:
            # [{:class=>"MakeCompanyReport", :args=>[1]}]
            # This is identical to the version from Resque::Plugins::UniqueJob
            # and we do not want the version from Resque::Plugins::LonelyJob to be used.
            # Payload is what Resque stored for this job along with the job's class name:
            # a hash containing :class and :args
            define_method(:redis_key) do |payload|
              puts "overriding redis_key in #{self}"
              begin
                payload = Resque.decode(Resque.encode(payload))
                job  = payload["class"]
                args = payload["args"]
                args.map! do |arg|
                  arg.is_a?(Hash) ? arg.sort : arg
                end
                # what is the configured arity for uniqueness?
                # minus one because zero indexed
                uniqueness_args = args[0..(configuration.arity_for_uniqueness - 1)]
                args = { class: job, args: uniqueness_args }
                key = Digest::MD5.hexdigest Resque.encode(args)
                puts "redis key for uniqueness for #{args} is: #{key.green}"
                key
              rescue => e
                Raven.captureMessage("redis_key error", extra: { signature: payload, error: e.class.to_s, message: e.message })
                raise e
              end
            end
          end
          if configuration.unique_at_runtime
            # The versions of redis_key from resque_solo and resque-lonely_job are incompatible.
            # So we forked resque-lonely_job, change the name of the method so it would not conflict,
            #   and now we can override it, and fix the params to be compatible with the redis_key
            #   from resque_solo
            # Does not need any customization for arity, because it funnels down to redis_key,
            #   and we handle the arity option there
            define_method(:lonely_job_redis_key) do |*args|
              puts "overriding lonely_job_redis_key in #{self}"
              "lonely_job:#{redis_key({"class" => self.to_s, "args" => args})}"
            end
          end
        end
      end
    end
  end
end
