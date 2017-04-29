require "resque-lonely_job"
require "resque_solo"

require "resque/unique_by_arity/version"
require "resque/unique_by_arity/configuration"
require "resque/unique_by_arity/cop"
require "resque/unique_by_arity/cop_modulizer"

# Usage:
#
# class MyJob
#   include UniqueByArity::Cop.new(
#     arity_for_uniqueness: 1,
#     unique_at_runtime: true,
#     unique_in_queue: true
#   )
# end
#
module Resque
  module UniqueByArity
    def unique_log(message, config_proxy = nil)
      config_proxy ||= self
      config_proxy.unique_logger.send(config_proxy.unique_log_level, message) if config_proxy.unique_logger
    end

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
    def uniqueness_lock_after_execution_period
      @uniqueness_configuration.lock_after_execution_period
    end
    def uniqueness_lock_after_execution_period=(lock_after_execution_period)
      @uniqueness_configuration.lock_after_execution_period = lock_after_execution_period
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
    self.uniqueness_configuration = Configuration.new # setup defaults
  end
end
