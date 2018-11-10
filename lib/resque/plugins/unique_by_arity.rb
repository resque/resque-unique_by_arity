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
        base.send(:extend, Resque::UniqueByArity)
        base.uniqueness_config_reset(@configuration.dup)

        # gem is resque-unique_in_queue, which is a rewrite of resque-solo / resque-loner
        # see: https://github.com/pboling/resque-unique_in_queue
        # defines a redis_key method, which we have to override.
        base.send(:include, Resque::Plugins::UniqueInQueue) if @configuration.unique_in_queue || @configuration.unique_across_queues

        # gem is resque-unique_at_runtime, which is a rewrite of resque-lonely_job
        # see: https://github.com/pboling/resque-unique_at_runtime
        base.send(:extend, Resque::Plugins::UniqueAtRuntime) if @configuration.unique_at_runtime

        uniqueness_cop_module = Resque::UniqueByArity::Modulizer.to_mod(@configuration)
        # This will override methods from both plugins above, if configured for both
        base.send(:extend, uniqueness_cop_module)

        base.include Resque::UniqueByArity::Validation unless @configuration.skip_arity_validation?
      end
    end
  end
end
