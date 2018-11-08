require 'resque/unique_by_arity/version'

# External Gems
require 'colorized_string'
require 'resque'

# External Resque Plugins
require 'resque-unique_in_queue'
require 'resque-unique_at_runtime'

require 'resque/plugins/unique_by_arity'
require 'resque/unique_by_arity/configuration'
require 'resque/unique_by_arity/modulizer'
require 'resque/unique_by_arity/validation'

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
    PLUGIN_TAG = (ColorizedString['[R-UBA] '].green).freeze

    def unique_log(message, config_proxy = nil)
      config_proxy ||= uniqueness_configuration
      config_proxy.unique_logger&.send(config_proxy.unique_log_level, message) if config_proxy.unique_logger
    end

    def unique_debug(message, config_proxy = nil)
      config_proxy ||= uniqueness_configuration
      config_proxy.unique_logger&.debug("#{Resque::UniqueByArity::PLUGIN_TAG}#{message}") if config_proxy.debug_mode
    end
    module_function(:unique_log, :unique_debug)

    # There are times when the class will need access to the configuration object,
    #   such as to override it per instance method
    def uniq_config
      @uniqueness_configuration
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
    def uniqueness_config_reset(config = Configuration.new)
      @uniqueness_configuration = config
    end

    def uniqueness_log_level
      @uniqueness_configuration.log_level
    end

    def uniqueness_log_level=(log_level)
      @uniqueness_configuration.log_level = log_level
    end

    def uniqueness_arity_for_uniqueness
      @uniqueness_configuration.arity_for_uniqueness
    end

    def uniqueness_arity_for_uniqueness=(arity_for_uniqueness)
      @uniqueness_configuration.arity_for_uniqueness = arity_for_uniqueness
    end

    def uniqueness_arity_validation
      @uniqueness_configuration.arity_validation
    end

    def uniqueness_arity_validation=(arity_validation)
      @uniqueness_configuration.arity_validation = arity_validation
    end

    def uniqueness_lock_after_execution_period
      @uniqueness_configuration.lock_after_execution_period
    end

    def uniqueness_lock_after_execution_period=(lock_after_execution_period)
      @uniqueness_configuration.lock_after_execution_period = lock_after_execution_period
    end

    def uniqueness_runtime_lock_timeout
      @uniqueness_configuration.runtime_lock_timeout
    end

    def uniqueness_runtime_lock_timeout=(runtime_lock_timeout)
      @uniqueness_configuration.runtime_lock_timeout = runtime_lock_timeout
    end

    def uniqueness_unique_at_runtime
      @uniqueness_configuration.unique_at_runtime
    end

    def uniqueness_unique_at_runtime=(unique_at_runtime)
      @uniqueness_configuration.unique_at_runtime = unique_at_runtime
    end

    def uniqueness_unique_in_queue
      @uniqueness_configuration.unique_in_queue
    end

    def uniqueness_unique_in_queue=(unique_in_queue)
      @uniqueness_configuration.unique_in_queue = unique_in_queue
    end

    def uniqueness_unique_across_queues
      @uniqueness_configuration.unique_across_queues
    end

    def uniqueness_unique_across_queues=(unique_across_queues)
      @uniqueness_configuration.unique_across_queues = unique_across_queues
    end
    self.uniqueness_configuration = Configuration.new # setup defaults
  end
end
