module Resque
  module UniqueByArity
    class Cop < Module
      def initialize(**config)
        @configuration = Resque::UniqueByArity::Configuration.new(**config)
      end
      def included(base)
        return unless @configuration
        base.send(:extend, Resque::UniqueByArity)
        base.uniqueness_config_reset(@configuration.dup)

        # gem is resque_solo, which is a rewrite of resque-loner
        # see: https://github.com/neighborland/resque_solo
        # defines a redis_key method, which we have to override.
        base.send(:include, Resque::Plugins::UniqueJob) if @configuration.unique_in_queue || @configuration.unique_across_queues

        # gem is resque-unique_at_runtime, which is a rewrite of resque-lonely_job
        # see: https://github.com/pboling/resque-unique_at_runtime
        base.send(:extend, Resque::Plugins::UniqueAtRuntime) if @configuration.unique_at_runtime

        uniqueness_cop_module = Resque::UniqueByArity::CopModulizer.to_mod(@configuration)
        # This will override methods from both plugins above, if configured for both
        base.send(:extend, uniqueness_cop_module)
        
        base.include Resque::UniqueByArity::Validation unless @configuration.skip_arity_validation?
      end
    end
  end
end
