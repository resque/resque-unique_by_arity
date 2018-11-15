# Usage:
#
# class MyJob
#   def self.perform(arg1, arg2)
#   end
#   include Resque::Plugins::UniqueByArity.new(
#     arity_for_uniqueness: 1,
#     arity_validation: :warning, # or nil, false, or :error
#     unique_at_runtime: true,
#     unique_in_queue: true
#   )
# end
#
# NOTE: DO NOT include this module directly.
#       Use the Resque::Plugins::UniqueByArity approach as above.
#       This module is ultimately extended into the job class.
module Resque
  module UniqueByArity
    module UniqueJob
      PLUGIN_TAG = (ColorizedString['[R-UBA] '].green).freeze

      def uniq_log(message, config_proxy = nil)
        config_proxy ||= uniq_config
        config_proxy.logger&.send(config_proxy.log_level, message) if config_proxy.logger
      end

      def uniq_debug(message, config_proxy = nil)
        config_proxy ||= uniq_config
        config_proxy.logger&.debug("#{Resque::UniqueByArity::PLUGIN_TAG}#{message}") if config_proxy.debug_mode
      end

      # For per-class config with a block
      def uniqueness_configure
        @uniqueness_configuration ||= Configuration.new
        yield(@uniqueness_configuration)
      end

      #### CONFIG ####
      class << self
        attr_accessor :uniqueness_configuration
      end
      self.uniqueness_configuration = Configuration.new # setup defaults

      def uniqueness_config_reset(config = Configuration.new)
        @uniqueness_configuration = config
      end

      def uniq_config
        @uniqueness_configuration
      end
    end
  end
end
