module Resque
  module Plugins
    # If you want your job to support uniqueness either at enqueue-time or at
    #   runtime, or both, and you want that uniqueness based on a specific arity
    #   of arguments, simply include this module into your job class.
    #
    # NOTE: This module gets instantiated.
    #       It is a module - class hybrid.
    #       That's unconventional, and extremely powerful.
    #
    #   class EnqueueAndRunAlone
    #     @queue = :enqueue_and_run_alone
    #
    #     def self.perform(arg1, arg2)
    #       alone_stuff
    #     end
    #     include Resque::Plugins::UniqueByArity.new(
    #       arity_for_uniqueness: 1,
    #       arity_validation: :warning, # or nil, false, or :error
    #       unique_at_runtime: true,
    #       unique_in_queue: true
    #     )
    #   end
    #
    class UniqueByArity < Module
      def initialize(**config)
        @configuration = Resque::UniqueByArity::Configuration.new(**config)
      end

      def included(base)
        return unless @configuration

        # We don't have access to the base class when initializing, but...
        #   we do initialize unique instances of the module for each class.
        # As a result we can configure per class.
        @configuration.base_klass_name = base.to_s
        @configuration.validate
        base.send(:extend, Resque::UniqueByArity::UniqueJob)
        base.uniqueness_config_reset(@configuration.dup)

        # gem is resque-unique_in_queue, which is a rewrite of resque-solo / resque-loner
        # see: https://github.com/pboling/resque-unique_in_queue
        # defines a redis_key method, which we have to override.
        base.send(:include, Resque::Plugins::UniqueInQueue) if @configuration.unique_in_queue || @configuration.unique_across_queues

        # gem is resque-unique_at_runtime, which is a rewrite of resque-lonely_job
        # see: https://github.com/pboling/resque-unique_at_runtime
        base.send(:include, Resque::Plugins::UniqueAtRuntime) if @configuration.unique_at_runtime

        # For resque-unique_at_runtime
        #
        if @configuration.runtime_lock_timeout
          base.instance_variable_set(:@runtime_lock_timeout, @configuration.runtime_lock_timeout)
        end

        if @configuration.runtime_requeue_interval
          base.instance_variable_set(:@runtime_requeue_interval, @configuration.runtime_requeue_interval)
        end

        if @configuration.unique_at_runtime_key_base
          base.instance_variable_set(:@unique_at_runtime_key_base, @configuration.unique_at_runtime_key_base)
        end

        # For resque-unique_in_queue
        #
        if @configuration.lock_after_execution_period
          base.instance_variable_set(:@lock_after_execution_period, @configuration.lock_after_execution_period)
        end

        if @configuration.ttl
          base.instance_variable_set(:@ttl, @configuration.ttl)
        end

        # Normally doesn't make sense to override per each class because
        #   it wouldn't be able to determine or enforce uniqueness across queues,
        #   and general cleanup of stray keys would be nearly impossible.
        if @configuration.unique_in_queue_key_base
          base.instance_variable_set(:@unique_in_queue_key_base, @configuration.unique_in_queue_key_base)
        end

        uniqueness_cop_module = Resque::UniqueByArity::Modulizer.to_mod(@configuration)
        # This will override methods from both plugins above, if configured for both
        base.send(:extend, uniqueness_cop_module)

        base.include Resque::UniqueByArity::Validation unless @configuration.skip_arity_validation?
      end
    end
  end
end
