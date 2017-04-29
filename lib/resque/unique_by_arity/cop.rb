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
        # defines a redis_key method, which if we are not careful, conflicts with a custom redis_key we set here
        base.send(:include, Resque::Plugins::UniqueJob) if @configuration.unique_in_queue

        # gem is resque-lonely_job
        # see: https://github.com/wallace/resque-lonely_job
        base.send(:extend, Resque::Plugins::LonelyJob) if @configuration.unique_at_runtime

        uniqueness_cop_module = Resque::UniqueByArity::CopModulizer.to_mod(@configuration)
        # This will override methods from both plugins above, if configured for both
        base.send(:extend, uniqueness_cop_module)
      end
    end
  end
end
